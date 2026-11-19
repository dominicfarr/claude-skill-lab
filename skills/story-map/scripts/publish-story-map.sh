#!/usr/bin/env bash
# Publishes a story map (journeys -> steps -> stories) as a parent GitHub issue
# plus one child issue per story, linked as sub-issues where gh supports it.
#
# Usage: publish-story-map.sh <path-to-map.json>
#
# Input JSON shape:
# {
#   "idea_title": "...",
#   "idea_summary": "...",
#   "journeys": [
#     { "name": "...", "steps": [
#       { "name": "...", "stories": [
#         { "title": "...", "in_slice": true, "gherkin": "Feature: ...\n..." }
#       ]}
#     ]}
#   ]
# }
#
# Prints a markdown summary table (story title, journey, step, issue number) on success.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <path-to-map.json>" >&2
  exit 2
fi

MAP_JSON="$1"

for bin in gh jq; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: $bin is required but not found on PATH" >&2
    exit 2
  fi
done

if [ ! -f "$MAP_JSON" ]; then
  echo "error: no such file: $MAP_JSON" >&2
  exit 2
fi

if ! jq empty "$MAP_JSON" >/dev/null 2>&1; then
  echo "error: $MAP_JSON is not valid JSON" >&2
  exit 2
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
OWNER="${REPO%/*}"
NAME="${REPO#*/}"

ensure_label() {
  local label="$1" color="$2" desc="$3"
  if ! gh label list --json name -q '.[].name' | grep -qx "$label"; then
    gh label create "$label" --color "$color" --description "$desc" >/dev/null
  fi
}

ensure_label "story-map" "5319E7" "Parent issue holding a User Story Map"
ensure_label "story" "0E8A16" "A single story card from a story map"

render_map_body() {
  jq -r '
    "## " + .idea_title + "\n\n" +
    (.idea_summary // "") + "\n\n" +
    "Legend: 🦴 = in the walking-skeleton slice (has BDD specs)\n\n" +
    (
      [.journeys[] |
        "### " + .name + "\n\n" +
        ([.steps[] |
          "**" + .name + "**\n" +
          ([.stories[] |
            "- " + (if .in_slice then "🦴 " else "" end) + .title
          ] | join("\n"))
        ] | join("\n\n"))
      ] | join("\n\n")
    )
  ' "$MAP_JSON"
}

MAP_BODY_FILE=$(mktemp)
trap 'rm -f "$MAP_BODY_FILE"' EXIT

render_map_body > "$MAP_BODY_FILE"

IDEA_TITLE=$(jq -r '.idea_title' "$MAP_JSON")

# `gh issue create` has no --json output flag, so parse the number from the URL it prints.
PARENT_URL=$(gh issue create \
  --title "Story Map: $IDEA_TITLE" \
  --body-file "$MAP_BODY_FILE" \
  --label "story-map")
PARENT_NUM="${PARENT_URL##*/}"

echo "Created map issue #$PARENT_NUM"

link_sub_issue() {
  local child_num="$1"
  if gh issue edit "$PARENT_NUM" --add-sub-issue "$child_num" >/dev/null 2>&1; then
    return 0
  fi
  local child_db_id
  child_db_id=$(gh api "repos/$OWNER/$NAME/issues/$child_num" --jq .id)
  gh api --method POST "repos/$OWNER/$NAME/issues/$PARENT_NUM/sub_issues" \
    -F "sub_issue_id=$child_db_id" >/dev/null 2>&1
}

SUMMARY_FILE=$(mktemp)
trap 'rm -f "$MAP_BODY_FILE" "$SUMMARY_FILE"' EXIT
echo "| Story | Journey | Step | Issue |" > "$SUMMARY_FILE"
echo "|---|---|---|---|" >> "$SUMMARY_FILE"

FALLBACK_USED=0

while IFS=$'\t' read -r JOURNEY STEP TITLE IN_SLICE GHERKIN; do
  BODY_FILE=$(mktemp)
  {
    echo "Journey: $JOURNEY > Step: $STEP"
    echo
    if [ "$IN_SLICE" = "true" ] && [ -n "$GHERKIN" ]; then
      echo '```gherkin'
      printf '%b\n' "$GHERKIN"
      echo '```'
    else
      echo "Not yet in the walking-skeleton slice. Plain story card pending a future pass."
    fi
  } > "$BODY_FILE"

  CHILD_URL=$(gh issue create --title "$TITLE" --body-file "$BODY_FILE" --label "story")
  CHILD_NUM="${CHILD_URL##*/}"
  rm -f "$BODY_FILE"

  if ! link_sub_issue "$CHILD_NUM"; then
    FALLBACK_USED=1
    gh issue comment "$CHILD_NUM" --body "Part of #$PARENT_NUM" >/dev/null 2>&1 || true
  fi

  echo "| $TITLE | $JOURNEY | $STEP | #$CHILD_NUM |" >> "$SUMMARY_FILE"
done < <(jq -r '
  .journeys[] as $j |
  $j.steps[] as $s |
  $s.stories[] |
  [$j.name, $s.name, .title, (.in_slice // false | tostring), (.gherkin // "")] | @tsv
' "$MAP_JSON")

echo
cat "$SUMMARY_FILE"

if [ "$FALLBACK_USED" = "1" ]; then
  echo
  echo "note: sub-issue linking wasn't available on this gh version for one or more stories; used a 'Part of #$PARENT_NUM' comment instead." >&2
fi
