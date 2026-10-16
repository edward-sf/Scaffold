# AGENTS.md

<!--
TEMPLATE NOTES — delete this block once filled in. Run /scaffold-init to do it for you.
Maintaining the Scaffold template itself? Read .scaffold/README.md instead; this file is a template.
- Fill every <placeholder>. Delete any section that doesn't apply rather than leaving it vague.
- Target: under ~100 lines. For every line ask: "Would removing this cause the agent to make a mistake?"
- Don't restate what tooling enforces (lint/format rules) or what the agent can read from the code.
- Point to exemplar files instead of pasting code snippets; snippets drift, files don't.
- This is the single source of project instructions; CLAUDE.md only imports it.
- Set CHECK_CMD in `.claude/hooks/check-before-stop.sh` to the "Full check" command below.
- Boundaries are enforced in `.claude/settings.json`: add `ask` rules for this project's
  migration paths, and `deny` Edit rules for its generated files.
-->

## Project

<One or two sentences: what this is and who it's for.>

- Stack: <language/runtime + major frameworks, e.g. TypeScript, Expo, Supabase, Express>
- Package manager: <pnpm | npm | uv | cargo> — do not use any other.
- Layout (non-obvious parts only):
  - `<path>/` — <what lives here>
  - `<path>/` — <what lives here>

## Commands

Run all commands from the repo root unless noted.

| Purpose | Command |
| --- | --- |
| Install | `<cmd>` |
| Run locally | `<cmd>` |
| Test one file | `<cmd> <path>` |
| Full check (typecheck + lint + tests) | `<cmd>` |
| Regenerate generated code | `<cmd>` |

Prefer running a single test file while iterating; run the full check before finishing.

## Definition of done

A task is not done until:

1. The full check passes with zero errors and zero warnings.
2. New behavior has tests. A bug fix starts with a failing test that reproduces the bug.
3. You report evidence: the commands you ran and their results. Do not claim success without it.
4. The diff contains only changes the task needs: no drive-by refactors, reformatting, or renames.

If a check fails and you can't fix the root cause, stop and explain. Never disable a check,
skip a test, or add a suppression comment to make it pass.

In Claude Code, a Stop hook runs the full check when you finish a turn with uncommitted
changes. Treat its output as a failing check, not as noise.

## Workflow

- For changes touching more than one or two files, propose a plan and wait for approval before editing.
  With the superpowers plugin, brainstorming then writing-plans covers this; specs and plans go in
  `docs/superpowers/` and are committed.
- Keep changes small and focused; one concern per branch and PR.
- When requirements are ambiguous, ask instead of guessing.
- Branches: `<type>/<short-description>` (e.g. `feat/pantry-restock`). Never commit to `main`.
- Commits: Conventional Commits (`feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`).
- PR description: what changed, why, how it was verified, anything left out of scope.
- Finish every branch with a PR, never a local merge into `main` (in superpowers'
  finishing-a-development-branch, choose "Push and create a Pull Request").

## Conventions

Only rules that differ from defaults or can't be inferred from the code. Style and formatting
are enforced by <linter/formatter>; follow their output rather than any rule written here.

- <e.g. Data fetching goes through hooks in `src/queries/`; follow `src/queries/useExample.ts`.>
- <e.g. Errors from the DB client are thrown, never returned as empty values.>
- <e.g. Use path aliases (`@/…`) instead of `../../` imports.>

## Boundaries

**Always:** <e.g. keep secrets in `.env.local` (gitignored); read `docs/<x>.md` before touching <area>>

**Ask first:**
- Adding, removing, or upgrading dependencies
- Database migrations or schema changes
- Changes to CI, build config, auth, or permissions
- Deleting files or tests

**Never:**
- Commit secrets, keys, or `.env` files
- Edit generated files (`<path>`) by hand; regenerate them with the command above
- Force-push, rewrite published history, or push directly to `main`
- Weaken security controls (e.g. <row-level security policies, auth checks>)

## Gotchas

<Things that have actually bitten you or the agent. Add one each time a mistake can't be
prevented by a test, lint rule, or hook. Remove when no longer true.>

- <e.g. Restart the dev server after changing env vars; it doesn't hot-reload them.>

## More context

- <Area skills in `.claude/skills/<area>/`, e.g. `database-rls` before touching policies>
  (copy `.claude/skills/example-area/` to add one)
- Subdirectories may have their own `AGENTS.md`; the closest one to the file you're editing takes precedence.