I've set up most of the project, but I couldn't make the first commit. Permission rules blocked writing `.pre-commit-config.yaml`, and the hooks can't be installed without it. I didn't try to get around the block.

**Done**, following the `new-project` steps in the standards repo's `PLAN.md`:
- Ran `git init` on branch `main`.
- Copied the standard files from `dominicfarr/dev-standards` at commit `ea7d5bd`, each with a first line naming that commit: `.gitignore`, `commitlint.config.mjs`, `.github/workflows/ci.yml`, `.github/dependabot.yml`, `CONTRIBUTING.md` and `docs/DEVELOPMENT.md`.
- Set up the agent-skills config. The `setup-matt-pocock-skills` skill isn't installed in this session, so I copied what it would produce instead: `docs/agents/issue-tracker.md` (GitHub), `docs/agents/triage-labels.md` (the default labels) and `docs/agents/domain.md` (single-context).
- Wrote `CLAUDE.md` with the "Read first" line and the agent-skills sections.
- Wrote a `README.md` with the CI badge and the standard *Development setup* section.
- Didn't create `GLOSSARY.md` or `docs/adr/`. The domain doc says those get created later, when the first terms and decisions come up.
- No GitHub repo and no labels, as you asked.

**Not done:**
1. **`.pre-commit-config.yaml` is missing.** It's flagged as a sensitive file, so the write needs your approval.
2. **Hooks not installed and no commit made.** Both depend on the file above.
3. **Copies not checked against the originals.** I tried to compare each file with the upstream version, but that command also needed approval. I typed the files out from the upstream content, so they should match, but I haven't confirmed it.

**To finish**, allow writes to `.pre-commit-config.yaml` and re-run me, or add the file yourself: it's the upstream file with `# from dominicfarr/dev-standards@ea7d5bd78d0dd869ba5335a2c2d38db2dcfaf044` as its first line. Then:

```sh
pre-commit install --install-hooks
git add -A
git commit -m "chore: create project from dev-standards"
```

pre-commit 4.7.0 and shellcheck are already on your PATH. The commit message passes the commitlint rules: `chore` is an allowed type, there's no scope, and the line is under 72 characters.
