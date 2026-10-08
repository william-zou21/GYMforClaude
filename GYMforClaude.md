# GYMforClaude: Gains from Your Mistakes

An agentic self-improvement protocol.

## Goal

Progressive overload for Claude Code sessions. Learn from friction, encode lessons as rules, apply them in future reps.

## The Reflection Rep

When the user says "run a GYMforClaude reflection" (or invokes `/gymforclaude`), perform these steps:

1. **Extract friction.** Run `bash ~/.claude/skills/gymforclaude/scripts/friction.sh 5` from the project root. If that file does not exist, fetch it first:
   `mkdir -p ~/.claude/skills/gymforclaude/scripts && curl -sSL https://raw.githubusercontent.com/william-zou21/GYMforClaude/main/skill/scripts/friction.sh -o ~/.claude/skills/gymforclaude/scripts/friction.sh`
   (requires `jq`). It locates transcripts for this repo and all of its worktrees under `~/.claude/projects/`, skips the live session and anything before the `last-reflected` watermark below, and prints each failed tool call (`CALL:`/`ERR:`), the next call the agent made after it (`NEXT:`, usually the fix), and each correcting user message (`USER:`). Do not hand-parse JSONL. If it reports no closed transcripts, stop here.

2. **Classify.** `Exit code N` with a later fix = failed command. Missing file / flag / package / API = hallucination. "The user doesn't want to proceed" = pushback. "Tool call interrupted" and "Shell cwd was reset" = noise, skip. MCP 404 / auth errors = environment, at most one rule.

3. **Scan the digest** for the pattern behind each signal: what the agent assumed, what was true, what fixed it.

4. **Distill ≤3 new rules.** Each rule is one imperative line that opens with its scope ("For Vercel deploys, ..."). Vague rules ("write better code") are useless — prefer concrete ones ("For icons in this repo, use `lucide-react`, not `@radix-ui/react-icons`").

5. **Dedupe or supersede.** Compare each candidate against the Personal Record below. Same advice → drop it. Same scope but different advice → edit the old line in place: `- [YYYY-MM-DD] <new rule> (supersedes <old date>: <old gist>)`. Only genuinely new scopes get appended.

6. **Append to Personal Record.** Format: `- [YYYY-MM-DD] <rule text>`

7. **Advance the watermark.** Set the `last-reflected` comment below to the epoch the script printed on its `WATERMARK:` line, even if no rules were added.

8. **Report to the user.** Print the rules you added or superseded (or "no new rules this rep"). Do not write anything else to the journal.

## Personal Record

If two rules below ever conflict, the later date wins.

<!-- last-reflected: 0 -->
<!-- rules appended below this line -->
