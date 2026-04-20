---
name: gymclaw
description: Run a GYMclaw reflection — scan the last few closed Claude Code session transcripts for hallucinations, failed commands, and user corrections, then distill up to 3 new rules and append them to GYMclaw.md in the project root. Triggers on "run a reflection", "gymclaw", "update the PRs", "workout journal".
---

# /gymclaw — Reflection Rep

You are running a GYMclaw reflection. Follow these steps in order.

## 1. Locate the transcript directory

Claude Code writes session transcripts to `~/.claude/projects/<CWD_ENCODED>/*.jsonl`, where `<CWD_ENCODED>` is the current working directory with every `/` replaced by `-`.

Compute it:

```bash
pwd | sed 's|/|-|g'
```

Then the full path is `~/.claude/projects/$(pwd | sed 's|/|-|g')/`.

## 2. Pick which sessions to read

List `*.jsonl` in that directory by modification time, newest first. **Skip the newest file** — that is the live session writing itself as you read. Take the next 5 (or fewer if not enough exist).

```bash
ls -t ~/.claude/projects/$(pwd | sed 's|/|-|g')/*.jsonl 2>/dev/null | tail -n +2 | head -n 5
```

## 3. Scan for friction signals

Each JSONL line is a JSON object. For each file, walk the lines and look for:

- **Hallucinations corrected by the user:** assistant claims a library / API / file / flag that does not exist, and the next user message points it out.
- **Failed bash calls:** `tool_use_result` entries with non-zero exits, paired with the follow-up fix.
- **User pushback:** user messages containing "no", "don't", "stop", "not like that", "wrong", "actually", or other corrections.

## 4. Distill ≤3 rules

Each rule is one imperative line. Prefer concrete, project-scoped rules over vague ones.

- Good: `In this repo, use lucide-react for icons, not @radix-ui/react-icons.`
- Bad: `Write better code.`

If you cannot find ≥1 real friction signal, it is fine to produce zero rules. Do not invent friction.

## 5. Dedupe

Read the existing `GYMclaw.md` in the project root. Skip any candidate rule that duplicates or near-duplicates one already in the **Personal Record** section.

If `GYMclaw.md` does not exist in the project root, tell the user to copy the template from the GYMclaw repo before running a reflection.

## 6. Append

Append surviving rules to `GYMclaw.md` under the **Personal Record** heading, in the format:

```
- [YYYY-MM-DD] <rule text>
```

Use today's date. Use the `Edit` tool with the existing "<!-- rules appended below this line -->" marker as your anchor to keep placement stable.

## 7. Report

Print the rules you added. If none were added (all duplicates, or no friction found), say so in one sentence. Do not narrate steps 1–6 to the user unless they ask.
