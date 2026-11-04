#!/usr/bin/env bash
# Copies the standard files and base gates from the standards repo's default
# branch into a new project, each with a source header naming the commit
# they were read from. Uses `gh api`; needs no local clone.
#
# Usage: copy-standards.sh <folder> <standards-owner>/<standards-repo>
# Prints the standards commit SHA on the last line of stdout.
#
# The files, at the same path in the project:
#   .gitignore, CONTRIBUTING.md, docs/DEVELOPMENT.md (the development
#   practices), .pre-commit-config.yaml, commitlint.config.mjs (read by the
#   commitlint hook), .github/workflows/ci.yml, .github/dependabot.yml.
# Hook fragments and Sonar templates are not copied here: the stack and
# Sonar tickets copy them later.
#
# Source header: line 1 of each copy, in the file's own comment syntax:
#   # from <owner>/<repo>@<sha>          YAML, .gitignore
#   <!-- from <owner>/<repo>@<sha> -->   Markdown
#   // from <owner>/<repo>@<sha>         JavaScript (.mjs)
# Every file in the set takes a comment on line 1. A file type with no
# comment syntax at all (such as JSON) is refused here rather than copied
# without a header; adding one means choosing its fallback first.
#
# Refuses to overwrite a file that already exists in the folder.
set -euo pipefail

folder="$(cd "${1:?usage: copy-standards.sh <folder> <owner>/<repo>}" && pwd)"
standards="${2:?usage: copy-standards.sh <folder> <owner>/<repo>}"

files=(
  ".gitignore"
  "CONTRIBUTING.md"
  "docs/DEVELOPMENT.md"
  ".pre-commit-config.yaml"
  "commitlint.config.mjs"
  ".github/workflows/ci.yml"
  ".github/dependabot.yml"
)

header_for() {
  local tag="from $standards@$2"
  case "$1" in
    *.md) echo "<!-- $tag -->" ;;
    *.mjs | *.js) echo "// $tag" ;;
    *.yml | *.yaml | .gitignore) echo "# $tag" ;;
    *) echo "ERROR: no source header rule for $1" >&2; return 1 ;;
  esac
}

for f in "${files[@]}"; do
  if [ -e "$folder/$f" ]; then
    echo "ERROR: $folder/$f already exists; not overwriting it" >&2
    exit 1
  fi
done

# HEAD resolves to the default branch. Pin every read to that one commit.
sha="$(gh api "repos/$standards/commits/HEAD" --jq .sha)"
if [[ ! "$sha" =~ ^[0-9a-f]{40}$ ]]; then
  echo "ERROR: could not resolve $standards default branch: $sha" >&2
  exit 1
fi

tmp="$(mktemp -d "${TMPDIR:-/tmp}/copy-standards.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

# Fetch everything before writing anything, so a failure leaves no partial copy.
for f in "${files[@]}"; do
  mkdir -p "$tmp/$(dirname "$f")"
  header_for "$f" "$sha" >"$tmp/$f"
  gh api "repos/$standards/contents/$f?ref=$sha" \
    -H "Accept: application/vnd.github.raw" >>"$tmp/$f"
done
for f in "${files[@]}"; do
  mkdir -p "$folder/$(dirname "$f")"
  cp "$tmp/$f" "$folder/$f"
  echo "copied $f"
done
echo "$sha"
