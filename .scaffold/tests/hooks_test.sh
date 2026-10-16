#!/usr/bin/env bash
# Exercises both hooks in a throwaway git repo.
set -euo pipefail
hooks="$(cd "$(dirname "$0")/../../.claude/hooks" && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
fail() { echo "  $*" >&2; exit 1; }
cd "$tmp" && git init -q -b main repo && cd repo
git -c user.name=t -c user.email=t@t commit -q --allow-empty -m init

# expect CODE SCRIPT INPUT: run a hook with INPUT on stdin and check its exit code.
expect() {
  local want="$1" script="$2" input="$3" got=0
  printf '%s' "$input" | bash "$script" >/dev/null 2>&1 || got=$?
  [ "$got" = "$want" ] || fail "$(basename "$script") <<< '$input' in $(pwd): want $want, got $got"
}

# no-commit-on-main
expect 2 "$hooks/no-commit-on-main.sh" '{}'
git switch -q -c feat/x
expect 0 "$hooks/no-commit-on-main.sh" '{}'

# check-before-stop: template default (empty CHECK_CMD) never blocks.
touch code.ts
expect 0 "$hooks/check-before-stop.sh" '{}'
rm code.ts

# check-before-stop with a check that passes only when ./ok exists.
stop="$tmp/stop.sh"
sed 's/^CHECK_CMD=""/CHECK_CMD="test -f ok"/' "$hooks/check-before-stop.sh" >"$stop"
grep -q '^CHECK_CMD="test -f ok"' "$stop" || fail "CHECK_CMD line not found in hook"
idle='{"stop_hook_active":false}'
expect 0 "$stop" "$idle"                                     # clean tree
mkdir -p docs/superpowers/specs && touch docs/superpowers/specs/a.md
expect 0 "$stop" "$idle"                                     # docs only, untracked
git add -A && git -c user.name=t -c user.email=t@t commit -qm docs
echo x >>docs/superpowers/specs/a.md
expect 0 "$stop" "$idle"                                     # docs only, modified
touch code.ts
expect 2 "$stop" "$idle"                                     # code changed, check fails
expect 0 "$stop" '{"stop_hook_active": true}'                # already continuing: don't loop
touch ok
expect 0 "$stop" "$idle"                                     # check passes
rm ok; mkdir -p sub && cd sub
expect 2 "$stop" "$idle"                                     # runs from repo root, not cwd
cd .. && rm code.ts && git checkout -q -- docs && git mv docs/superpowers/specs/a.md a.md
expect 2 "$stop" "$idle"                                     # rename out of docs/ counts
