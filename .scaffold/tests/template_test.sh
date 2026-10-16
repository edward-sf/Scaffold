#!/usr/bin/env bash
# Structural checks: the files /scaffold-init relies on exist and the template stays lean.
set -uo pipefail
problems=0
fail() { echo "  $*" >&2; problems=1; }

[ "$(cat CLAUDE.md)" = "@AGENTS.md" ] || fail "CLAUDE.md must contain only @AGENTS.md"

for f in AGENTS.md README.md .gitignore .gitattributes .editorconfig \
         .github/pull_request_template.md .github/dependabot.yml \
         .scaffold/files/ci.yml .claude/skills/example-area/SKILL.md \
         .claude/skills/scaffold-init/SKILL.md; do
  [ -f "$f" ] || fail "missing $f"
done

# Every path the init skill mentions must exist, so it doesn't drift from the template.
for p in $(grep -oE '`(\.[a-z]+/[^` ]+|[A-Z]+\.md)`' .claude/skills/scaffold-init/SKILL.md \
           | tr -d '`' | grep -v '[<*]' | sort -u); do
  [ -e "$p" ] || [ "$p" = ".github/workflows/ci.yml" ] || fail "scaffold-init mentions missing path: $p"
done

# The init skill's placeholder grep must catch every placeholder line in the templates,
# and nothing in files that survive init.
pattern="$(grep -oE "grep -rnE '[^']+'" .claude/skills/scaffold-init/SKILL.md | sed "s/^grep -rnE '//; s/'\$//")"
[ -n "$pattern" ] || fail "can't find the placeholder grep in scaffold-init"
for f in AGENTS.md README.md; do
  missed="$(sed '/^<!--$/,/^-->$/d' "$f" | grep '<' | grep -vE -- "$pattern")"
  [ -z "$missed" ] || fail "placeholder grep misses in $f: $missed"
done
leftover="$(grep -rnE --exclude-dir=example-area --exclude-dir=scaffold-init -- "$pattern" .github .claude)"
[ -z "$leftover" ] || fail "placeholder grep flags files that survive init: $leftover"

# Skills: frontmatter name matches the folder.
for s in .claude/skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$s")")"
  grep -q "^name: $dir\$" "$s" || fail "$s: name doesn't match folder $dir"
done

# AGENTS.md stays under ~100 lines once the template notes are removed.
lines="$(sed '/^<!--$/,/^-->$/d' AGENTS.md | wc -l)"
[ "$lines" -le 100 ] || fail "AGENTS.md is $lines lines without template notes (limit 100)"

# Shell scripts must have LF endings to run under bash on Linux. (Not grep: Git Bash's
# grep strips CR before matching.)
for f in $(git ls-files '*.sh') .scaffold/tests/*.sh; do
  [ "$(tr -d '\r' <"$f" | wc -c)" = "$(wc -c <"$f")" ] || fail "$f has CRLF line endings"
done

exit "$problems"
