#!/usr/bin/env bash
# Stop: run the project's full check before the agent ends a turn that changed files.
# Enforces the AGENTS.md "Definition of done". On failure, the output goes back to the
# agent and it keeps working. It blocks once per turn; after that the agent may stop
# and explain, as AGENTS.md asks.

# Set to the "Full check" command from AGENTS.md. Empty disables the hook.
CHECK_CMD=""

[ -n "$CHECK_CMD" ] || exit 0
input="$(cat)"
# Already continuing because of this hook: don't block again.
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

# Repo root from the current directory, not CLAUDE_PROJECT_DIR (fixed to the main
# checkout even in worktree sessions).
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
# Skip when nothing changed (a question-and-answer turn) or only docs/ changed
# (e.g. a superpowers spec or plan), so writing a spec doesn't trigger a full test run.
changed="$(git status --porcelain -uall 2>/dev/null | cut -c4- | sed 's/.* -> //')"
printf '%s\n' "$changed" | grep -qv -e '^docs/' -e '^$' || exit 0

if ! out="$(bash -c "$CHECK_CMD" 2>&1)"; then
  {
    echo "Full check failed (\`$CHECK_CMD\`). Fix the root cause, or explain why you can't."
    echo "Last 40 lines of output:"
    printf '%s\n' "$out" | tail -n 40
  } >&2
  exit 2
fi
exit 0
