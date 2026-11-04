#!/usr/bin/env bash
# Install check: add this repo as a marketplace in a throwaway Claude Code
# config dir, install the plugin, and confirm every skill under skills/ loads.
# Usage: scripts/test-plugin-install.sh [marketplace-source]
#   marketplace-source defaults to this repo's root; pass e.g.
#   dominicfarr/claude-skill-lab to test the published GitHub repo.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
source="${1:-$repo_root}"
plugin_id="skill-lab@skill-lab"

config_dir="$(mktemp -d)"
trap 'rm -rf "$config_dir"' EXIT
export CLAUDE_CONFIG_DIR="$config_dir"

claude plugin validate "$repo_root"
claude plugin marketplace add "$source"
claude plugin install "$plugin_id"

details="$(claude plugin details "$plugin_id")"
echo "$details"

status=0
for skill_md in "$repo_root"/skills/*/SKILL.md; do
  skill="$(basename "$(dirname "$skill_md")")"
  if grep -q "$skill" <<<"$details"; then
    echo "PASS: $skill loaded"
  else
    echo "FAIL: $skill not loaded"
    status=1
  fi
done
exit "$status"
