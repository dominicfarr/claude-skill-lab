#!/usr/bin/env bash
# Runs the new-project evals in scratch folders under $TMPDIR, with and
# without the skill, grades each folder with check.sh and records the
# outputs under evals/runs/iteration-<n>/.
#
# Usage: evals/run-evals.sh <iteration> [with_skill|without_skill|both] [eval-id...]
#   Defaults: both variants, every eval in evals.json.
#
# Safety: no eval may create a GitHub repo. Each claude run gets:
#   - a scoped tool allowlist (no blanket permission bypass): file tools,
#     git, read-only gh, pre-commit, uv tool and the skill's own scripts
#   - deny rules for every GitHub write and for git push / remote add
#   - a gh guard first on PATH (gh-guard/gh refuses every GitHub write)
#   - a folder name no repo has; check.sh confirms dominicfarr/<folder>
#     still does not exist afterwards.
set -euo pipefail

evals_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$evals_dir/../../.." && pwd)"
skill_scripts="$repo_root/skills/new-project/scripts"
iteration="${1:?usage: run-evals.sh <iteration> [with_skill|without_skill|both] [eval-id...]}"
variant_arg="${2:-both}"
shift $(($# >= 2 ? 2 : $#))
ids=("$@")
if [ "${#ids[@]}" -eq 0 ]; then
  while IFS= read -r id; do ids+=("$id"); done < <(jq -r '.evals[].id' "$evals_dir/evals.json")
fi
case "$variant_arg" in
  both) variants=(with_skill without_skill) ;;
  with_skill | without_skill) variants=("$variant_arg") ;;
  *) echo "bad variant: $variant_arg" >&2; exit 2 ;;
esac

REAL_GH="$(command -v gh)"
export REAL_GH
scratch="${TMPDIR:-/tmp}/new-project-evals/iteration-$iteration"
results="$evals_dir/runs/iteration-$iteration"
prompt="$(jq -r .prompt "$evals_dir/evals.json")"
with_prompt="$(jq -r .with_prompt "$evals_dir/evals.json")"

allowed=(
  Read Write Edit Glob Grep Skill
  "Bash(git:*)" "Bash(gh api:*)" "Bash(gh repo view:*)" "Bash(gh auth status:*)"
  "Bash(pre-commit:*)" "Bash(uv tool:*)"
  "Bash($skill_scripts/check-safe.sh:*)" "Bash($skill_scripts/copy-standards.sh:*)"
  "Bash(ls:*)" "Bash(cat:*)" "Bash(head:*)" "Bash(pwd)" "Bash(basename:*)"
  "Bash(mkdir:*)" "Bash(test:*)" "Bash(sort:*)" "Bash(grep:*)" "Bash(find:*)"
)
disallowed=(
  "Bash(gh repo create:*)" "Bash(gh repo delete:*)" "Bash(gh repo edit:*)"
  "Bash(gh label create:*)" "Bash(gh issue create:*)" "Bash(gh secret set:*)"
  "Bash(git push:*)" "Bash(git remote add:*)"
)

# make_fixture <kind> <case-dir>: prints the project folder it created.
make_fixture() {
  local kind="$1" case_dir="$2" project
  mkdir -p "$case_dir/fixture"
  case "$kind" in
    refuse-name) project="$case_dir/claude-skill-lab" ;;
    *) project="$case_dir/np-eval-$kind-$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6)" ;;
  esac
  mkdir -p "$project"
  case "$kind" in
    idea)
      printf '# Idea\n\nA tiny app that tracks which houseplants need water today.\n' >"$project/IDEA.md"
      cp "$project/IDEA.md" "$case_dir/fixture/IDEA.md"
      ;;
    refuse-history)
      git -C "$project" init -q -b main
      printf '# Notes\n\nExisting work.\n' >"$project/notes.md"
      git -C "$project" add notes.md
      git -C "$project" -c commit.gpgsign=false commit -q -m "docs: add notes"
      git -C "$project" rev-parse HEAD >"$case_dir/fixture/original-head"
      ;;
  esac
  echo "$project"
}

run_case() {
  local id="$1" variant="$2" kind case_dir project out p
  kind="$(jq -r ".evals[] | select(.id == $id) | .kind" "$evals_dir/evals.json")"
  case_dir="$scratch/eval-$id/$variant"
  rm -rf "$case_dir"
  project="$(make_fixture "$kind" "$case_dir")"
  out="$results/eval-$id/$variant/outputs"
  mkdir -p "$out"
  local args=(-p --max-budget-usd 10 --allowedTools "${allowed[@]}" --disallowedTools "${disallowed[@]}")
  if [ "$variant" = with_skill ]; then
    p="$with_prompt"
    args+=(--plugin-dir "$repo_root")
  else
    p="$prompt"
  fi
  echo "eval-$id/$variant: $project"
  (
    cd "$project"
    PATH="$evals_dir/gh-guard:$PATH" GH_GUARD_LOG="$case_dir/gh.log" \
      claude "${args[@]}" -- "$p" >"$out/result.md" 2>&1 || true
  )
  cp "$case_dir/gh.log" "$out/gh.log" 2>/dev/null || : >"$out/gh.log"
  "$evals_dir/check.sh" "$kind" "$project" "$out/result.md" >"$out/check.txt" 2>&1 || true
  jq -Rn --arg project "$project" --arg variant "$variant" '
    {variant: $variant, project: $project,
     assertions: [inputs | select(test("^(PASS|FAIL) "))
       | capture("^(?<r>PASS|FAIL) (?<id>[^:]+): (?<evidence>.*)$")
       | {id, passed: (.r == "PASS"), evidence}]}
    | .passed = ([.assertions[] | select(.passed)] | length)
    | .total = (.assertions | length)' <"$out/check.txt" >"$out/grading.json"
  echo "eval-$id/$variant: $(jq -r '"\(.passed)/\(.total) passed"' "$out/grading.json")"
}

pids=()
for id in "${ids[@]}"; do
  mkdir -p "$results/eval-$id"
  jq ".evals[] | select(.id == $id) | {eval_id: .id, eval_name: .name, kind, fixture, prompt: \$prompt, with_prompt: \$with_prompt, assertions}" \
    --arg prompt "$prompt" --arg with_prompt "$with_prompt" \
    "$evals_dir/evals.json" >"$results/eval-$id/eval_metadata.json"
  for variant in "${variants[@]}"; do
    run_case "$id" "$variant" &
    pids+=($!)
  done
done
status=0
for pid in "${pids[@]}"; do wait "$pid" || status=1; done

echo
for id in "${ids[@]}"; do
  for variant in "${variants[@]}"; do
    g="$results/eval-$id/$variant/outputs/grading.json"
    [ -f "$g" ] && printf 'eval-%s %-13s %s\n' "$id" "$variant" "$(jq -r '"\(.passed)/\(.total)"' "$g")"
  done
done
exit "$status"
