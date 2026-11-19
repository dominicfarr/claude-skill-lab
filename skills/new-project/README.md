# new-project

Turns an empty folder (or one holding only an idea note) into a project using Dom's standards, up to a gated first commit, then creates and pushes the GitHub repo.

**Trigger:** `/skill-lab:new-project [repo-name]`. Pass `--local-only` to stop after the first local commit and skip creating/pushing the GitHub repo.

**Inputs:** a target folder/repo name; optional `--local-only`.

**Outputs:** an initialized `main` branch with the standard files and base gates copied in, `CLAUDE.md`, a README with a *Development setup* section, `pre-commit`/`commit-msg` hooks installed, and a first commit that passes them. Unless `--local-only`: a pushed public `dominicfarr/<repo-name>` repo with its triage labels created and the first CI run watched.

**Requires:** `gh` (logged in), `uv`, `pre-commit`, the `mattpocock-skills` plugin.

## Behavior

- Refuses a folder that already has git history, or sits inside another repo.
- Refuses a repo name `dominicfarr` already owns.
- Every copied standards file gets a source header on its first line naming the commit it came from (`# from dominicfarr/dev-standards@<sha>`, in that file's own comment syntax). A file type with no comment syntax is refused rather than copied without a header.
- The copied-file list (`.gitignore`, `CONTRIBUTING.md`, `docs/DEVELOPMENT.md`, `.pre-commit-config.yaml`, `commitlint.config.mjs`, `.github/workflows/ci.yml`, `.github/dependabot.yml`) lives in `scripts/copy-standards.sh` — that script is the source of truth, not this file.

## Evals

```sh
skills/new-project/evals/run-evals.sh <iteration>               # every eval, with and without the skill
skills/new-project/evals/run-evals.sh <iteration> with_skill 1   # one eval, one variant
```

Each eval runs in an isolated scratch folder with `git push` and GitHub writes denied, so no eval can create a real repo.
