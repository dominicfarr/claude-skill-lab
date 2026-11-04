#!/usr/bin/env bash
# Install check: add this repo as a marketplace in a throwaway Claude Code
# config dir, install the plugin, and confirm every skill under skills/ loads.
# Usage: scripts/test-plugin-install.sh [marketplace-source]
#   marketplace-source defaults to this repo's root; pass e.g.
#   dominicfarr/claude-skill-lab to test the published GitHub repo.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
marketplace_source="${1:-$repo_root}"
plugin_id="skill-lab@skill-lab"

config_dir="$(mktemp -d)"
trap 'rm -rf "$config_dir"' EXIT
export CLAUDE_CONFIG_DIR="$config_dir"

claude plugin validate "$repo_root"
claude plugin marketplace add "$marketplace_source"
claude plugin install "$plugin_id"

details="$(claude plugin details "$plugin_id")"
echo "$details"

# The inventory line reads "Skills (2)  name-a, name-b": one loaded skill
# name per line, so each check below is an exact match, not a substring.
loaded="$(sed -nE 's/^[[:space:]]*Skills \([0-9]+\)[[:space:]]*//p' <<<"$details" |
  tr ',' '\n' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

status=0
for skill_md in "$repo_root"/skills/*/SKILL.md; do
  skill="$(basename "$(dirname "$skill_md")")"
  if grep -qxF -- "$skill" <<<"$loaded"; then
    echo "PASS: $skill loaded"
  else
    echo "FAIL: $skill not loaded"
    status=1
  fi
done
exit "$status"
