#!/usr/bin/env bash
# Runs every template test from the repo root. Exits non-zero if any fail.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
status=0
for t in .scaffold/tests/*_test.sh .scaffold/tests/*_test.mjs; do
  case "$t" in *.mjs) cmd=(node "$t") ;; *) cmd=(bash "$t") ;; esac
  if "${cmd[@]}"; then echo "ok   $t"; else echo "FAIL $t"; status=1; fi
done
exit "$status"
