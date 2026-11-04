#!/usr/bin/env bash
# Safety check for new-project. Read-only.
#
# Usage: check-safe.sh <folder> <owner>/<repo-name>
#
# Exit 0: safe to create the project here.
# Exit 1: refused, with the reason on stderr:
#   - the folder already has git history (a commit on any ref)
#   - the folder sits inside another git work tree
#   - the repo name is not a valid GitHub name
#   - the GitHub repo <owner>/<repo-name> already exists
# Exit 2: the check itself failed (for example GitHub unreachable).
set -euo pipefail

folder="$(cd "${1:?usage: check-safe.sh <folder> <owner>/<repo-name>}" && pwd)"
full_name="${2:?usage: check-safe.sh <folder> <owner>/<repo-name>}"
name="${full_name#*/}"

refuse() { echo "REFUSED: $1" >&2; exit 1; }

if [ -e "$folder/.git" ]; then
  if [ -n "$(git -C "$folder" rev-list -n 1 --all 2>/dev/null)" ]; then
    refuse "$folder already has git history; new-project only starts fresh repos"
  fi
elif top="$(git -C "$folder" rev-parse --show-toplevel 2>/dev/null)"; then
  refuse "$folder is inside the git repo $top"
fi

if [[ ! "$name" =~ ^[A-Za-z0-9._-]+$ ]] || [ "$name" = . ] || [ "$name" = .. ]; then
  refuse "'$name' is not a valid GitHub repo name"
fi

if out="$(gh api "repos/$full_name" --jq .full_name 2>&1)"; then
  refuse "the GitHub repo $out already exists"
elif ! grep -q 'HTTP 404' <<<"$out"; then
  echo "ERROR: could not check GitHub for $full_name: $out" >&2
  exit 2
fi

echo "SAFE: $folder has no git history and $full_name is free"
