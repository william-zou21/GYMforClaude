# GYMclaw: Agentic Self-Improvement Protocol

## Goal

Progressive overload for Claude Code sessions. Learn from friction, encode lessons as rules, apply them in future reps.

## The Reflection Rep

When the user says "run a GYMclaw reflection" (or invokes `/gymclaw`), perform these steps:

1. **Locate the transcript directory.** Claude Code stores sessions at `~/.claude/projects/<CWD_ENCODED>/*.jsonl`, where `<CWD_ENCODED>` is the current working directory with every `/` replaced by `-` (e.g. `/Users/jane/app` becomes `-Users-jane-app`). Compute it from `pwd`.

2. **Pick which sessions to read.** List `*.jsonl` in that dir sorted by modification time (newest first). **Skip the newest file** — that is the currently-running session, writing itself as you read. Read the next 5 files (or fewer if not enough exist).

3. **Scan for friction signals.** In each session, walk the JSONL lines and look for:
   - Assistant hallucinations that the user corrected (non-existent libraries, APIs, file paths, flags).
   - Bash tool calls that exited non-zero, and what the follow-up fix was.
   - User messages that say "no", "don't", "stop", "not like that", "wrong", or otherwise push back on an approach.

4. **Distill ≤3 new rules.** Each rule is one imperative line, project-specific where possible. Vague rules ("write better code") are useless — prefer concrete ones ("in this repo, use `lucide-react` for icons, not `@radix-ui/react-icons`").

5. **Dedupe before appending.** Read the existing Personal Record below. Skip any rule that duplicates or near-duplicates one already present.

6. **Append to Personal Record.** Format: `- [YYYY-MM-DD] <rule text>`

7. **Report to the user.** Print the rules you added (or "no new rules this rep" if all were dupes or no friction was found). Do not write anything else to the journal.

## Personal Record

<!-- rules appended below this line -->
