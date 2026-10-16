---
name: scaffold-init
description: One-time setup for a new project created from the Scaffold template. Fills in AGENTS.md and README.md, configures the check hook, permissions, CI and Dependabot, then removes the template-only files. Run once, right after creating the repo.
disable-model-invocation: true
---

Turn this freshly templated repo into a configured project. Work through the steps in order.
Infer everything you can from the repo; ask me only for what you can't, in one batch per step.
Never leave a `<placeholder>`: replace it, or delete the line or section it belongs to.

## 1. Prepare

- If the tree has uncommitted changes, stop and ask.
- If on `main`, create `chore/scaffold-init`.
- Survey the repo: manifests and lockfiles, scripts, source layout, existing docs and CI.
  An empty repo is normal for a new project. If so, ask me for the stack, package manager,
  and what the project is, then continue from my answers.

## 2. AGENTS.md

Fill in every placeholder in `AGENTS.md`, following the rules in its template notes (lean,
no restating tooling, point to exemplar files). Commands must be real: run each one that can
run now. Mark commands that will exist only once code exists with a `# TODO` next to them, and
tell me. Delete sections and example bullets that don't apply. Then delete the template notes
comment block.

## 3. README.md

Fill in `README.md` from the same facts. Keep commands in AGENTS.md only; the README links there.

## 4. Check hook

Set `CHECK_CMD` in `.claude/hooks/check-before-stop.sh` to the AGENTS.md "Full check" command.
If the full check can't run yet, leave it empty and add a Gotchas bullet in AGENTS.md saying
the hook is off until it's set.

## 5. Permissions

In `.claude/settings.json`:
- Remove `ask` rules for package managers this project doesn't use.
- Add `ask` Edit rules for migration paths, e.g. `Edit(/supabase/migrations/**)`.
- Add `deny` Edit rules for generated files, e.g. `Edit(/src/gen/**)`.
- Leave the deny rules for `.env`, force pushes, and pushes to `main` as they are.

## 6. .gitignore

Append the standard entries for the stack (build output, dependency directories, caches,
coverage). Keep the existing entries.

## 7. CI and Dependabot

1. Ask me which standards workflow fits the stack (e.g. `ci-python.yml`). If `gh` is available
   and authenticated, list the options with `gh api repos/edward-sf/standards/contents/.github/workflows`.
2. Find the latest standards release with `git ls-remote --tags https://github.com/edward-sf/standards`
   (or `gh release view -R edward-sf/standards`). Pin the exact tag, e.g. `v1.3.0`, never a branch.
3. Copy `.scaffold/files/ci.yml` to `.github/workflows/ci.yml` and fill in `<stack>` and `<version>`.
4. Add the project's package ecosystem (npm, pip, cargo, nuget) to `.github/dependabot.yml`,
   next to the existing github-actions entry.
5. Don't change GitHub settings yourself. In the final summary, tell me to make the `ci` job a
   required check in the repo's ruleset. If the standards repo is private, also tell me to
   allow access to its workflows under its Settings > Actions > General.

## 8. Area skills

Ask whether any area needs its own skill now (auth, database, payments, a pipeline). For each
one, copy `.claude/skills/example-area/` to `.claude/skills/<area>/` and fill it in from what
I tell you. Then delete `.claude/skills/example-area/`, and list the new skills under
"More context" in AGENTS.md.

## 9. Remove template-only files

Delete `.scaffold/`, `.github/workflows/scaffold.yml`, and this skill's folder
`.claude/skills/scaffold-init/`.

## 10. Verify and commit

1. Placeholders: `grep -rnE '<[A-Za-z][^>]*(>|$)' AGENTS.md README.md .github .claude` should print
   nothing. HTML comments (`<!--`) in the PR template don't match and are fine.
2. `CHECK_CMD` is set, or the AGENTS.md Gotchas bullet says why not.
3. `.github/workflows/ci.yml` has no `<` left.
4. If the full check can run, run it.
5. Commit as `chore: initialize project from scaffold` and show me the summary, including the
   manual GitHub steps from 7.5. Offer to push and open a PR.
