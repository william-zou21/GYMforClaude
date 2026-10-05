#!/usr/bin/env bash
# GYMforClaude friction extractor. Prints a compact friction digest from Claude Code
# session transcripts so the agent reads ~hundreds of lines, not megabytes of JSONL.
#
# Usage: friction.sh [N_SESSIONS]   (default 5)
# Requires: jq
set -euo pipefail
N="${1:-5}"
command -v jq >/dev/null || { echo "jq is required (brew install jq)" >&2; exit 2; }

# Encode cwd the way Claude Code does: every non-alphanumeric char becomes '-'.
# e.g. /Users/me/app/.claude/worktrees/x -> -Users-me-app--claude-worktrees-x
ENC="$(pwd | sed 's|[^A-Za-z0-9]|-|g')"
# Strip a worktree suffix so a worktree session also sees its parent repo's history.
ROOT="${ENC%%--claude-worktrees-*}"
PROJ="$HOME/.claude/projects"

# Collect transcripts for the repo root and every worktree under it, newest first.
# Skip the live session (SESSION_ID from env, else the single newest file).
FILES="$(ls -t "$PROJ"/"$ROOT"/*.jsonl "$PROJ"/"$ROOT"--claude-worktrees-*/*.jsonl 2>/dev/null || true)"
if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
  FILES="$(printf '%s\n' "$FILES" | grep -v "$CLAUDE_SESSION_ID" || true)"
else
  FILES="$(printf '%s\n' "$FILES" | tail -n +2)"
fi
FILES="$(printf '%s\n' "$FILES" | grep . | head -n "$N" || true)"

if [ -z "$FILES" ]; then
  echo "No closed transcripts found under $PROJ/$ROOT*/ (only the live session exists, or transcripts were cleaned up)."
  echo "Tip: transcripts older than cleanupPeriodDays (default 30) are deleted by Claude Code."
  exit 0
fi

for f in $FILES; do
  echo "=== $(basename "$f") ($(date -r "$f" '+%Y-%m-%d %H:%M'), $(jq -r 'select(.cwd!=null)|.cwd' "$f" | head -1))"
  echo "--- failed tool calls"
  # One pass: every tool_use and every errored tool_result, in file order. For each error,
  # print the call that caused it and the NEXT call the agent made (usually the fix).
  jq -r -n '
    [inputs] | to_entries | map(.key as $i | .value
      | if .type=="assistant" then
          (.message.content[]? | select(.type=="tool_use")
           | {i:$i, kind:"use", id:.id, text:"\(.name) \(.input|tostring|.[0:200])"})
        elif .type=="user" then
          (.message.content[]? | select(type=="object" and .type=="tool_result" and .is_error==true)
           | {i:$i, kind:"err", id:.tool_use_id,
              text:(.content | if type=="array" then map(.text? // "") | join(" ") else tostring end
                    | gsub("\n";" ") | .[0:300])})
        else empty end) as $ev
    | $ev[] | select(.kind=="err") | . as $e
    | "  CALL: " + (($ev[] | select(.kind=="use" and .id==$e.id) | .text) // "<unknown>")
    + "\n  ERR : " + $e.text
    + "\n  NEXT: " + (([$ev[] | select(.kind=="use" and .i > $e.i)] | first | .text) // "<none>")
  ' "$f" || true
  echo "--- user pushback"
  # Human-typed user messages (not tool results) with correction language.
  jq -r '
    select(.type=="user" and .isSidechain!=true)
    | .message.content
    | if type=="string" then . else (map(select(type=="object" and .type=="text") | .text) | join(" ")) end
    | select(length>0)
    | select(test("\\b(no|don.t|stop|wrong|not like that|actually|instead|undo|revert|why did you|that.s not|doesn.t exist|user error)\\b"; "i"))
    | "  USER: " + (gsub("\n";" ") | .[0:300])' "$f" || true
done
