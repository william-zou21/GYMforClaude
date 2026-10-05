---
name: gymclaw
description: Run a GYMclaw reflection — scan the last few closed Claude Code session transcripts for hallucinations, failed commands, and user corrections, then distill up to 3 new rules and append them to GYMclaw.md in the project root. Triggers on "run a reflection", "gymclaw", "update the PRs", "workout journal".
---

# /gymclaw — Reflection Rep

You are running a GYMclaw reflection. Follow these steps in order.

## 1. Extract friction

Do not read raw JSONL by hand. Run the bundled extractor from the project root:

```bash
bash ~/.claude/skills/gymclaw/scripts/friction.sh 5
```

It finds the transcripts for this repo **and every worktree under it**, skips the live session, and prints per session:

- `CALL:` / `ERR:` / `NEXT:` triples — every tool call whose result was flagged `is_error`, the input that caused it, and the next call the agent made (usually the fix).
- `USER:` lines — human messages containing correction language.

If the script is missing, fetch it first with the curl command from the README's install section. If it prints "No closed transcripts found", say so and stop. Do not invent friction.

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

- Good: `In this repo, use lucide-react for icons, not @radix-ui/react-icons.`
- Good: `The Vercel MCP get_auth_user call 404s on this account; use list_teams first.`
- Bad: `Write better code.`

Zero rules is a valid outcome.

## 4. Dedupe

Read the existing `GYMclaw.md` in the project root. Skip any candidate that duplicates or near-duplicates one already in the **Personal Record** section.

If `GYMclaw.md` does not exist in the project root, tell the user to copy the template from the GYMclaw repo before running a reflection.

## 5. Append

Append surviving rules under the **Personal Record** heading:

```
- [YYYY-MM-DD] <rule text>
```

Use today's date. Use the `Edit` tool with the existing `<!-- rules appended below this line -->` marker as your anchor to keep placement stable.

## 6. Report

Print the rules you added. If none were added, say so in one sentence. Do not narrate steps 1–5 unless asked.
