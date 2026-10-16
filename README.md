# Scaffold
Template repo for standardized scaffolding of new projects.

## What's included

| Path | Purpose |
| --- | --- |
| `AGENTS.md` | Project instructions for any coding agent. Fill in the placeholders for each new project. |
| `CLAUDE.md` | Just `@AGENTS.md`, so Claude Code loads the same instructions. Put project rules in `AGENTS.md`, not here. |
| `.claude/settings.json` | Enables the [superpowers](https://github.com/obra/superpowers) plugin, sets permissions that enforce the `AGENTS.md` boundaries, and registers the hooks below. |
| `.claude/hooks/no-commit-on-main.sh` | Blocks agent commits on `main`/`master`. |
| `.claude/hooks/check-before-stop.sh` | Runs the full check when the agent finishes a turn with uncommitted changes outside `docs/`, and sends failures back to it. Off until you set `CHECK_CMD`. |
| `.claude/skills/example-area/` | Template for area skills (auth, database, pipelines). Copy and rename it, then delete it. |
| `.github/pull_request_template.md` | Mirrors the PR rules and definition of done in `AGENTS.md`. |
| `.gitattributes`, `.editorconfig` | LF everywhere (so hooks run under Git Bash on Windows), UTF-8, and baseline indentation. |
| `.gitignore` | Agent working state (`HANDOFF.md`, `.worktrees/`), personal overrides, and env files. |

## Superpowers

The template assumes the superpowers workflow: brainstorming, then a plan, then test-driven execution, then a PR. Claude Code prompts you to install the plugin the first time you trust a project made from this template. The scaffold only adds where it differs from the plugin's defaults:

- Specs and plans are committed under `docs/superpowers/`, and the stop hook ignores `docs/`-only changes.
- Worktrees go in `.worktrees/`, which is already gitignored, so the plugin doesn't need to commit that change itself.
- Branches finish as PRs. `AGENTS.md` says so, and `git merge` and pushes ask first, so the plugin's local-merge option needs your approval.

## Starting a project

1. Fill in `AGENTS.md` and delete its template notes.
2. Set `CHECK_CMD` in `.claude/hooks/check-before-stop.sh` to the full check command.
3. In `.claude/settings.json`, add `ask` rules for migration paths and `deny` Edit rules for generated files.
4. Add language-specific entries to `.gitignore`.
5. Replace `.claude/skills/example-area/` with real area skills, or delete it.

## Permissions at a glance

Read-only commands like `git status`, `ls` and `grep` are allowed by Claude Code itself, so they aren't listed.

- **Allow:** `git add`, `git commit`, and creating or switching branches. The hook still blocks commits on `main`.
- **Ask:** pushes, merges, history rewrites (`reset --hard`, `clean`, `rebase`), dependency changes for npm, pnpm, yarn, uv, pip, cargo and dotnet, and edits to `.github/` or `.claude/`.
- **Deny:** force pushes, pushes to `main`, and reading or editing `.env` files (`.env.example` is allowed).

These rules match the commands the agent usually writes. They're guardrails, not a security boundary.

## Not included, by design

- **Shared agent tooling** (the `scout` agent, the `/handoff` skill, the status line, personal preferences) lives in
  [edward-sf/skills](https://github.com/edward-sf/skills) and is installed once per machine with its
  `install.sh`. Improvements reach every project without re-copying.
- **CI workflows and rules** live in the standards repo.
