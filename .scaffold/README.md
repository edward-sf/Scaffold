# Scaffold

Template repo for new projects: agent instructions, Claude Code guardrails, and the wiring into
[edward-sf/standards](https://github.com/edward-sf/standards) CI. Everything in `.scaffold/` is for
maintaining the template and is deleted when a project is set up. The root `README.md` is the new
project's README template.

## Starting a project

1. On GitHub, choose **Use this template** and create the repo. Clone it and open Claude Code.
2. Trust the folder, and install superpowers when prompted.
3. Run `/scaffold-init`. It fills in `AGENTS.md` and `README.md`, then sets the check hook,
   permissions, `.gitignore`, CI and Dependabot. It also creates any area skills you ask for and
   removes the template-only files. Then it commits on `chore/scaffold-init`.
4. Do the GitHub steps it lists. Make the `ci` job a required check in the repo's ruleset. If
   the standards repo is private, allow access to its workflows from this repo.

## What a project gets

| Path | Purpose |
| --- | --- |
| `AGENTS.md` | Project instructions for any coding agent, and the single source of truth for commands and rules. |
| `CLAUDE.md` | Just `@AGENTS.md`, so Claude Code loads the same instructions. |
| `README.md` | Short human-facing intro that links to `AGENTS.md` for commands. |
| `.claude/settings.json` | Enables superpowers, sets permissions that enforce the `AGENTS.md` boundaries, and registers the hooks. |
| `.claude/hooks/no-commit-on-main.sh` | Blocks agent commits on `main`/`master`. |
| `.claude/hooks/check-before-stop.sh` | Runs the full check when the agent finishes a turn with changes outside `docs/`, and sends failures back to it. |
| `.claude/skills/<area>/` | Area skills created from `example-area` during init. |
| `.github/workflows/ci.yml` | Calls the standards repo's reusable CI, pinned to a release tag. Created from `.scaffold/files/ci.yml`. |
| `.github/dependabot.yml` | Opens PRs when the standards repo releases, and for the project's dependencies. |
| `.github/pull_request_template.md` | Mirrors the PR rules and definition of done in `AGENTS.md`. |
| `.gitattributes`, `.editorconfig` | LF everywhere (so hooks run under Git Bash on Windows), UTF-8, and baseline indentation. |
| `.gitignore` | Agent working state (`HANDOFF.md`, `.worktrees/`), personal overrides, env files, and stack entries. |

## How the pieces divide

| Repo | Holds | Reaches projects by |
| --- | --- | --- |
| Scaffold (this) | Per-project starting files and the CI caller | One-time copy at project creation |
| [standards](https://github.com/edward-sf/standards) | Reusable CI, Semgrep rules, commitlint and PR checklist rules | Versioned `workflow_call`, required check, Dependabot upgrade PRs |
| [skills](https://github.com/edward-sf/skills) | Personal agent tooling: `scout`, `/handoff`, status line, preferences | `install.sh` into `~/.claude/` on each machine |
| [superpowers](https://github.com/obra/superpowers) | Development workflow skills | Plugin, enabled per project in `.claude/settings.json` |

Anything that must be enforced belongs in standards, because only standards can block a merge. The
scaffold's hooks and permissions are guardrails for the agent, not controls.

## Superpowers

The template assumes the superpowers workflow: brainstorming, then a plan, then test-driven
execution, then a PR. The scaffold only adds where it differs from the plugin's defaults:

- Specs and plans are committed under `docs/superpowers/`, and the stop hook ignores `docs/`-only changes.
- Worktrees go in `.worktrees/`, which is already gitignored.
- Branches finish as PRs. `AGENTS.md` says so, and `git merge` and pushes ask first.

## Permissions at a glance

Read-only commands like `git status`, `ls` and `grep` are allowed by Claude Code itself, so they aren't listed.

- **Allow:** `git add`, `git commit`, and creating or switching branches. The hook still blocks commits on `main`.
- **Ask:** pushes, merges, history rewrites (`reset --hard`, `clean`, `rebase`), dependency changes, and edits to `.github/` or `.claude/`.
- **Deny:** force pushes, pushes to `main`, and reading or editing `.env` files (`.env.example` is allowed).

## Maintaining the template

- **Test:** `bash .scaffold/tests/run.sh`. It checks both hooks against a throwaway repo, lints
  `settings.json` for rule shapes Claude Code ignores, and checks the template's structure, including
  that every path `/scaffold-init` mentions exists. CI runs it through `.github/workflows/scaffold.yml`,
  but only in this repo.
- **After changing settings or hooks,** open one Claude Code session here to confirm there are no
  startup warnings. Bad permission rules only show up there.
- **Keep the init skill in step with the template.** If you add a placeholder or a template-only
  file, update `.claude/skills/scaffold-init/SKILL.md`.
- **Updates don't reach existing projects.** A template is a one-time copy. That's acceptable while
  the template stays thin and anything enforceable lives in standards. If you end up with several
  long-lived projects that need template updates, convert this repo to [copier](https://copier.readthedocs.io/),
  which records the template version in each project and merges updates with `copier update`.
