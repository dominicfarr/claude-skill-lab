I got most of the way, but there's no first commit yet. Writing `.pre-commit-config.yaml` into the project needs your approval because the harness treats it as a sensitive file, and this session couldn't ask. That file defines the hooks, so I couldn't install them or commit without it. I didn't try to get around the block with a shell copy.

**Done so far:** I followed the `new-project` steps from the standards repo's `PLAN.md`, copying from `dominicfarr/dev-standards` at commit `ea7d5bd`:
- Ran `git init` on `main`.
- Copied these files unchanged, each with a source-header line naming that commit: `.gitignore`, `CONTRIBUTING.md`, `commitlint.config.mjs`, `.github/workflows/ci.yml`, `.github/dependabot.yml`, `docs/DEVELOPMENT.md`, and `docs/agents/{issue-tracker,triage-labels,domain}.md`.
- Wrote `CLAUDE.md` with the "Read first" line and the Agent skills block, and added `IDEA.md` to the reading list.
- Wrote `README.md` with the CI badge, a pointer to `IDEA.md` and the Development setup section. The badge assumes the GitHub repo will be named after this folder (`np-eval-idea-h9lkxw`).
- No license, which is the standard.
- I didn't create a GitHub repo or labels.

**Left undone and why:**
- **No `.pre-commit-config.yaml` in the project.** The exact content (base gates, with its source header) is ready at `/private/tmp/claude-502/-private-var-folders-jw-tj23tl8j3kjb5kcylkss3knc0000gp-T-new-project-evals-iteration-1-eval-2-without-skill-np-eval-idea-h9lkxw/2f8a9fdb-e50f-4a4e-8dd8-4c43ae1c4573/scratchpad/pre-commit-config.yaml`.
- **Hooks not installed and nothing committed**, because both depend on that file.
- **No automated check that my copies match the originals.** I retyped each file by hand from the fetched text. The tools I'd have used to compare them against upstream also needed approval.

**To finish:** approve the write and I'll carry on, or do it yourself:
```sh
cp /private/tmp/claude-502/-private-var-folders-jw-tj23tl8j3kjb5kcylkss3knc0000gp-T-new-project-evals-iteration-1-eval-2-without-skill-np-eval-idea-h9lkxw/2f8a9fdb-e50f-4a4e-8dd8-4c43ae1c4573/scratchpad/pre-commit-config.yaml .pre-commit-config.yaml
pre-commit install --install-hooks
git add -A
git commit -m "chore: bootstrap project from dev-standards"
```
The tools the hooks need are already installed: uv, pre-commit 4.7.0 (the version CI uses) and shellcheck. If any hook fails, fix the cause, `git add -u` and commit again, without `--no-verify`.

**Expected gaps:** `docs/DEVELOPMENT.md` is an exact copy, so it still links to `GLOSSARY.md`, the ADR, `templates/` and `scripts/gate-proof.sh`, which aren't in this project. The standards expect `GLOSSARY.md` and the ADR folder to come from the first grilling. Templates arrive with the Sonar ticket.
