---
name: new-project
description: Turn an empty or near-empty folder into a project with Dom's standards, up to a gated first commit.
disable-model-invocation: true
argument-hint: "[repo-name] [--local-only]"
---

# new-project

Turns the current folder (empty, or holding only notes such as an idea file) into a **project**: standard files and **base gates** copied from the **standards repo** with **source headers**, the Matt Pocock skills set up, `CLAUDE.md` pointing at the development practices, hooks installed, and a first commit that passes them. Bold terms are defined in the standards repo's `GLOSSARY.md`.

## Constants

```sh
OWNER=dominicfarr                     # GitHub owner of new projects
STANDARDS=dominicfarr/dev-standards   # the standards repo, read from its default branch
```

`scripts/` sits beside this file, in this skill's base directory. Run its scripts by full path.

## Arguments

- **Repo name:** the first argument that isn't a flag; otherwise the folder's name.
- **`--local-only`:** stop after step 8. Evals pass it.

Run every step from the project folder, in order. Each ends on a check; finish the check before moving on.

## 1. Refuse unsafe folders

```sh
<skill-dir>/scripts/check-safe.sh "$PWD" "$OWNER/<repo-name>"
```

Exit 0 means safe. Exit 1 means **refuse**: the folder has git history, sits inside another repo, or the GitHub repo name is taken. Exit 2 means the check couldn't run. On 1 or 2, stop with the folder exactly as you found it and report the script's reason to Dom. Overriding a refusal is Dom's call, made by moving or renaming, never by this skill.

## 2. Start the repo on `main`

`git init -b main`. If an empty `.git` already exists (no commits, which step 1 allowed), run `git symbolic-ref HEAD refs/heads/main` instead.

**Done when** `git symbolic-ref --short HEAD` prints `main`.

## 3. Copy the standard files and base gates

```sh
<skill-dir>/scripts/copy-standards.sh "$PWD" "$STANDARDS"
```

It reads the standards repo's default branch through `gh api`, pins every read to that branch's head commit, writes each file with a source header naming that commit, and prints the SHA on its last line. Keep the SHA for step 8. The script's header comment lists the files and the header syntax for each file type. Copy them verbatim: the source header is the only change.

**Done when** the script exits 0. On failure, report its error and stop.

## 4. Set up the Matt Pocock skills

Do what `setup-matt-pocock-skills` does, with Dom's answers already given: **GitHub** issue tracker, the **default triage labels**, **single-context** domain docs, and `CLAUDE.md` as the file to edit. That skill is user-invoked, so the Skill tool can't run it: write its output yourself from its seed templates, asking Dom nothing.

Find its folder, highest version first:

```sh
ls -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/mattpocock-skills/*/skills/engineering/setup-matt-pocock-skills | sort -V | tail -n 1
```

If there is none, stop and tell Dom to install the `mattpocock-skills` plugin. Otherwise copy, unchanged:

| Seed template | Project file |
|---|---|
| `issue-tracker-github.md` | `docs/agents/issue-tracker.md` |
| `triage-labels.md` | `docs/agents/triage-labels.md` |
| `domain.md` | `docs/agents/domain.md` |

The labels themselves are created in step 9, once the GitHub repo exists.

## 5. Write `CLAUDE.md`

Create `CLAUDE.md` with exactly this content: the "Read first" line, then the `## Agent skills` block.

```markdown
Read first: `PLAN.md`, `GLOSSARY.md`, `docs/adr/`, `docs/DEVELOPMENT.md` (the development practices: every standard as settled scope, and the tickets each trigger implies, such as choosing a stack), and `CONTRIBUTING.md`.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues (via `gh`). See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
```

`PLAN.md`, `GLOSSARY.md` and `docs/adr/` arrive with the first grilling; listing them now is intended. If the folder already had a `CLAUDE.md`, keep its content and add the "Read first" line at the top and the block after it, replacing any existing `## Agent skills` block.

## 6. Write the README

`CONTRIBUTING.md` sends readers to the README's *Development setup*, and `ci.yml` pins pre-commit to match it. Read the pin from the `uv tool install --no-build pre-commit==<pin>` line in `.github/workflows/ci.yml`, then write `README.md`:

````markdown
# <repo-name>

[![CI](https://github.com/<OWNER>/<repo-name>/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/<OWNER>/<repo-name>/actions/workflows/ci.yml)

<One line from the idea note, if there is one; otherwise leave this line out.>

## Development setup

You need:

- [uv](https://docs.astral.sh/uv/)
- pre-commit: `uv tool install pre-commit==<pin>` (the version CI uses; bump both together)
- shellcheck: `brew install shellcheck`, or `uv tool install shellcheck-py`

Then install the hooks for both the `pre-commit` and `commit-msg` stages:

```sh
pre-commit install --install-hooks
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow and the commit message format, and [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for the development practices.
````

If a `README.md` already exists, it is Dom's note: leave it as it is and say in the report that it lacks *Development setup*. Leave every other file already in the folder untouched too.

## 7. Install the hooks for both stages

1. `pre-commit --version` should print the pin from step 6. If pre-commit is missing, run `uv tool install --no-build pre-commit==<pin>`. If a different version is installed, carry on and note the mismatch in the report.
2. `pre-commit install --install-hooks`. The config's `default_install_hook_types` covers `pre-commit` and `commit-msg`.

**Done when** both `.git/hooks/pre-commit` and `.git/hooks/commit-msg` exist and contain `File generated by pre-commit`.

## 8. Make the gated first commit

```sh
git add -A
git commit -F - <<'EOF'
chore: create project from dev-standards

Standard files and base gates copied from dominicfarr/dev-standards
at commit <sha from step 3>.
EOF
```

The commit goes through the hooks. If a hook fails or changes files, fix the cause, `git add -A`, and commit again with the same message, until it passes. Every commit goes through the hooks, this one included.

**Done when** `git rev-list --count HEAD` prints `1`, `git status --porcelain` prints nothing, and `git log -1 --format=%s` shows the message above.

With `--local-only`, stop here and report.

## 9. Create the GitHub repo and labels (not built yet)

**Stub, filled by dominicfarr/dev-standards#10.** This step will create the public repo from the folder, push `main`, and create the triage labels the repo lacks. Evals pass `--local-only` and stop before it.

Until #10 lands, stop after step 8: leave the repo local, with no remote, and tell Dom this step is still to come.

## Report

Tell Dom, briefly:
- the folder and repo name, and the standards commit SHA in the source headers
- the files copied and written, and anything already in the folder that was kept
- the first commit's SHA and subject, and that it passed the hooks
- anything noted on the way (pre-commit version mismatch, an existing README)
- what's next: step 9 (until #10 lands), then grill the project with `grill-with-docs`
