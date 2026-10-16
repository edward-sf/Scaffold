#!/usr/bin/env bash
# PreToolUse (Bash, `git commit *`): refuse commits on the default branch.
# Enforces the AGENTS.md rule "Never commit to main".
# Current directory, not CLAUDE_PROJECT_DIR: that stays on the main checkout in worktrees.
branch="$(git branch --show-current 2>/dev/null)"
case "$branch" in
  main|master)
    echo "Don't commit on '$branch'. Create a branch first, e.g. git switch -c feat/short-description" >&2
    exit 2 ;;
esac
exit 0
