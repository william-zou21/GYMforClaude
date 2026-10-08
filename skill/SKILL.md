---
name: gymforclaude
description: Run a GYMforClaude reflection — scan the last few closed Claude Code session transcripts for hallucinations, failed commands, and user corrections, then distill up to 3 new rules and append them to GYMforClaude.md in the project root. Triggers on "run a reflection", "gymforclaude", "update the PRs", "workout journal".
---

# /gymforclaude — Reflection Rep

You are running a GYMforClaude reflection. Follow these steps in order.

## 1. Extract friction

Do not read raw JSONL by hand. Run the bundled extractor from the project root:

```bash
bash ~/.claude/skills/gymforclaude/scripts/friction.sh 5
```

It finds the transcripts for this repo **and every worktree under it**, skips the live session, skips anything already reflected on (via the `last-reflected` watermark in `GYMforClaude.md`), and prints per session:

- `CALL:` / `ERR:` / `NEXT:` triples — every tool call whose result was flagged `is_error`, the input that caused it, and the next call the agent made (usually the fix).
- `USER:` lines — human messages containing correction language.

The last line is `WATERMARK: <epoch> (<date>)`; keep it for step 6.

If the script is missing, fetch it first with the curl command from the README's install section. If it prints "No closed transcripts found" or "Nothing new this rep", say so and stop. Do not invent friction.

Why a script: Claude Code encodes the project path by replacing every non-alphanumeric character with `-` (so `.claude` becomes `-claude`), and the desktop app gives each worktree its own transcript directory holding only its own live session. Hand-computing the path from `pwd` finds nothing.

## 2. Classify each signal

Not every `ERR:` is the agent's fault. Sort them:

| Signal | Treat as |
|---|---|
| `Exit code N` from Bash with a later fix in the same session | **Failed command** — the fix is the rule. |
| Error names a missing file, flag, package, or API | **Hallucination** — the rule names the real one. |
| `The user doesn't want to proceed with this tool use` | **Pushback** — the user vetoed the approach. |
| `Tool call interrupted: the session ended` | Noise. Skip. |
| `Shell cwd was reset to ...` | Noise. Skip. |
| MCP tool returns 404 / auth / not-found | **Environment**, not agent error. One rule at most, e.g. "check X is connected before calling it". |

## 3. Distill ≤3 rules

Each rule is one imperative line. Prefer concrete, project-scoped rules over vague ones.

Start each rule with its scope so later reps can tell when a new rule replaces it.

- Good: `For icons in this repo, use lucide-react, not @radix-ui/react-icons.`
- Good: `For Vercel MCP calls, skip get_auth_user (404s on this account); call list_teams first.`
- Bad: `Write better code.` (no scope, nothing to supersede)

Zero rules is a valid outcome.

## 4. Dedupe or supersede

Read the existing `GYMforClaude.md` in the project root and compare each candidate against the **Personal Record**:

- **Same rule, same advice** → drop the candidate.
- **Same scope, different advice** → the candidate supersedes. Edit the old line in place rather than appending, so the record never holds two live answers for one situation:

  ```
  - [2026-10-19] For Vercel deploys, do Y. (supersedes 2026-10-05: do X)
  ```

- **New scope** → append in step 5.

If `GYMforClaude.md` does not exist in the project root, tell the user to copy the template from the GYMforClaude repo before running a reflection.

## 5. Append

Append surviving rules under the **Personal Record** heading:

```
- [YYYY-MM-DD] <rule text>
```

Use today's date. Use the `Edit` tool with the existing `<!-- rules appended below this line -->` marker as your anchor to keep placement stable.

## 6. Advance the watermark

Replace the `<!-- last-reflected: ... -->` comment in `GYMforClaude.md` with the epoch from the script's `WATERMARK:` line (add the comment directly under the Personal Record heading if it is missing). Do this even when zero rules were added, so the next rep skips these sessions.

## 7. Report

Print the rules you added or superseded. If none, say so in one sentence. Do not narrate steps 1–6 unless asked.
