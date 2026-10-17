#!/usr/bin/env bash
# Structural checks: the files /scaffold-init relies on exist and the template stays lean.
set -uo pipefail
problems=0
fail() { echo "  $*" >&2; problems=1; }

[ "$(cat CLAUDE.md)" = "@AGENTS.md" ] || fail "CLAUDE.md must contain only @AGENTS.md"

for f in AGENTS.md README.md .gitignore .gitattributes .editorconfig \
         .github/pull_request_template.md .github/dependabot.yml \
         .scaffold/files/ci.yml .scaffold/files/pr-policy.yml .claude/skills/example-area/SKILL.md \
         .claude/skills/scaffold-init/SKILL.md; do
  [ -f "$f" ] || fail "missing $f"
done

# Every path the init skill mentions must exist, so it doesn't drift from the template. Caller
# workflows are created by init, so they're exempt.
for p in $(grep -oE '`(\.[a-z]+/[^` ]+|[A-Z]+\.md)`' .claude/skills/scaffold-init/SKILL.md \
           | tr -d '`' | grep -v '[<*]' | sort -u); do
  [ -e "$p" ] || case "$p" in .github/workflows/*) ;; *) false ;; esac || fail "scaffold-init mentions missing path: $p"
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

# The PR template is a copy of the standards one, whose checklist pr-policy enforces. A drifted
# copy would make every project PR fail the checklist check. Compare against the latest release,
# the tag /scaffold-init pins, not main, which can hold unreleased changes.
standards_ref="${STANDARDS_REF:-$(git ls-remote --tags --refs https://github.com/edward-sf/standards 'v*' 2>/dev/null \
  | sed 's|.*refs/tags/||' | sort -V | tail -n 1)}"
standards_template=""
[ -n "$standards_ref" ] && standards_template="$(curl -fsSL --max-time 20 "https://raw.githubusercontent.com/edward-sf/standards/$standards_ref/.github/pull_request_template.md")"
if [ -z "$standards_template" ]; then
  echo "  skipped: couldn't fetch the standards PR template" >&2
elif [ "$standards_template" != "$(cat .github/pull_request_template.md)" ]; then
  fail ".github/pull_request_template.md differs from edward-sf/standards; copy it from there"
fi

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
