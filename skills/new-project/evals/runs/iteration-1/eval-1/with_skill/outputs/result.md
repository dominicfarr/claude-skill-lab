The project is set up locally. The first commit passed the hooks, and I stopped after step 8 as `--local-only` asks.

- **Folder / repo:** `np-eval-create-mghpa7`. The safety check passed: no git history, and `dominicfarr/np-eval-create-mghpa7` is free on GitHub. The repo is on `main`.
- **Standards commit in the source headers:** `ea7d5bd78d0dd869ba5335a2c2d38db2dcfaf044`
- **Copied from dev-standards:** `.gitignore`, `CONTRIBUTING.md`, `docs/DEVELOPMENT.md`, `.pre-commit-config.yaml`, `commitlint.config.mjs`, `.github/workflows/ci.yml`, `.github/dependabot.yml`
- **Written:**
  - `docs/agents/issue-tracker.md`, `triage-labels.md` and `domain.md`, from mattpocock-skills 1.3.1, the only version installed.
  - `CLAUDE.md` with the "Read first" line and the Agent skills block.
  - `README.md` with the CI badge and *Development setup*. The pre-commit pin is `4.7.0`. There was no idea note, so the README has no description line.
- **Kept:** nothing. The folder was empty.
- **First commit:** `8055c45`, "chore: create project from dev-standards". The secrets, Actions-lint and commitlint hooks passed; shellcheck had no files to check and was skipped. There is 1 commit and the working tree is clean.

**Noted on the way:**
- The installed pre-commit is 4.7.0, which matches the pin.
- `cp` and `cmp` against the plugin cache were blocked by permissions. I read the three templates and wrote their contents out unchanged instead, but I couldn't compare the copies byte for byte.

**Next:**
1. Step 9: create the GitHub repo, push `main` and add the triage labels. It is still a stub until dominicfarr/dev-standards#10 lands, so the repo has no remote yet.
2. Grill the project with `grill-with-docs`.
