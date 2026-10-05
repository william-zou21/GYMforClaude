# GYMforClaude
![alt text](claw-gym.PNG)

**G.Y.M. = Gains from Your Mistakes.** A workout journal for your AI agent.

AI agents plateau without feedback. GYMforClaude is a tiny, zero-dependency self-improvement protocol for [Claude Code](https://claude.com/claude-code): your agent reads its own past session transcripts, spots where it hallucinated / failed commands / got corrected, and appends distilled rules to a local `GYMforClaude.md` — the "Personal Record" it trains against next rep.

No daemon, no cron, no dashboard. One markdown file. You trigger the reflection when you want it.

## What gets caught

- **Hallucinations** — non-existent libraries, APIs, file paths, flags that the user corrected.
- **Failed commands** — bash calls that exited non-zero and what the fix was.
- **Pushback** — moments the user said "no", "don't", "stop", "not like that".

## Install

### Minimal (template only)

Drop the template into your project root and install the extractor script (requires `jq`):

```bash
curl -sSLO https://raw.githubusercontent.com/william-zou21/GYMforClaude/main/GYMforClaude.md
mkdir -p ~/.claude/skills/gymforclaude/scripts
curl -sSL https://raw.githubusercontent.com/william-zou21/GYMforClaude/main/skill/scripts/friction.sh \
  -o ~/.claude/skills/gymforclaude/scripts/friction.sh
```

Then invoke:

```bash
claude -p "run a GYMforClaude reflection"
```

### As a Claude Code skill (recommended)

Install the skill once so you can trigger reflections with `/gymforclaude`:

```bash
mkdir -p ~/.claude/skills/gymforclaude/scripts
curl -sSL https://raw.githubusercontent.com/william-zou21/GYMforClaude/main/skill/SKILL.md \
  -o ~/.claude/skills/gymforclaude/SKILL.md
curl -sSL https://raw.githubusercontent.com/william-zou21/GYMforClaude/main/skill/scripts/friction.sh \
  -o ~/.claude/skills/gymforclaude/scripts/friction.sh
```

Requires `jq` (`brew install jq`).

Then, in any project, drop a `GYMforClaude.md` at the root and run `/gymforclaude` inside a Claude Code session.

## How it works

Claude Code stores every session as a JSONL file under `~/.claude/projects/<CWD_ENCODED>/`, where `<CWD_ENCODED>` is your project path with every non-alphanumeric character replaced by `-`. The desktop app runs each session in a git worktree, so a repo's history is spread across `<repo>` and `<repo>--claude-worktrees-<name>` directories, each holding only its own sessions.

When you run a reflection, the skill:

1. Runs `scripts/friction.sh`, which globs the repo directory **and all its worktree directories**, sorts by mtime, and drops the live session.
2. For the next 5 transcripts, prints every tool call whose result was flagged `is_error`, paired with the input that caused it and the next call the agent made (usually the fix), and every user message containing correction language. The agent reads a few hundred lines of digest instead of megabytes of JSONL.
3. Classifies each signal: failed command, hallucination, pushback, environment error, or noise (interrupted calls, cwd resets).
4. Distills up to 3 new rules, deduped against what's already in the Personal Record.
5. Appends them to `GYMforClaude.md` with today's date.

That's the whole thing.

## Caveats

- **Not automated.** You invoke it. Consider running it at the end of a working session.
- **Transcripts expire.** Claude Code deletes transcripts older than `cleanupPeriodDays` (default 30). Raise it in `~/.claude/settings.json` if you want a longer memory.
- **Quality follows your last 5 reps.** If you rarely correct the agent, there's nothing to learn from.
- **Prune occasionally.** The Personal Record grows. Old / superseded rules should be removed by hand.
- **Scope:** this is a single-file Claude Code convention, not a product. If you want automation or dashboards, fork it.

## License

MIT — see [LICENSE](./LICENSE).

Built by [Will Zou](https://github.com/william-zou21).
