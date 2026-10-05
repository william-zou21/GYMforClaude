# GYMforClaude: Gains from Your Mistakes

An agentic self-improvement protocol.

## Goal

Progressive overload for Claude Code sessions. Learn from friction, encode lessons as rules, apply them in future reps.

## The Reflection Rep

When the user says "run a GYMforClaude reflection" (or invokes `/gymforclaude`), perform these steps:

1. **Extract friction.** Run `bash ~/.claude/skills/gymforclaude/scripts/friction.sh 5` from the project root. If that file does not exist, fetch it first:
   `mkdir -p ~/.claude/skills/gymforclaude/scripts && curl -sSL https://raw.githubusercontent.com/william-zou21/gymclaw/main/skill/scripts/friction.sh -o ~/.claude/skills/gymforclaude/scripts/friction.sh`
   (requires `jq`). It locates transcripts for this repo and all of its worktrees under `~/.claude/projects/`, skips the live session, and prints each failed tool call (`CALL:`/`ERR:`), the next call the agent made after it (`NEXT:`, usually the fix), and each correcting user message (`USER:`). Do not hand-parse JSONL. If it reports no closed transcripts, stop here.

2. **Classify.** `Exit code N` with a later fix = failed command. Missing file / flag / package / API = hallucination. "The user doesn't want to proceed" = pushback. "Tool call interrupted" and "Shell cwd was reset" = noise, skip. MCP 404 / auth errors = environment, at most one rule.

3. **Scan the digest** for the pattern behind each signal: what the agent assumed, what was true, what fixed it.

4. **Distill ≤3 new rules.** Each rule is one imperative line, project-specific where possible. Vague rules ("write better code") are useless — prefer concrete ones ("in this repo, use `lucide-react` for icons, not `@radix-ui/react-icons`").

5. **Dedupe before appending.** Read the existing Personal Record below. Skip any rule that duplicates or near-duplicates one already present.

6. **Append to Personal Record.** Format: `- [YYYY-MM-DD] <rule text>`

7. **Report to the user.** Print the rules you added (or "no new rules this rep" if all were dupes or no friction was found). Do not write anything else to the journal.

## Personal Record

<!-- rules appended below this line -->
