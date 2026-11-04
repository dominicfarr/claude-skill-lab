I stopped before changing anything. Nothing in the folder has been touched.

**Why I stopped:** Dom's standards (the `new-project` step list in `PLAN.md` of `dominicfarr/dev-standards`) are written for an empty or nearly empty folder. The first step is `git init` on `main`, and the last is a first commit that passes the hooks. `PLAN.md` also lists "Retrofitting existing repos" as out of scope.

This folder already has a repo with history:

- branch `main`, one commit: `cde5fd4 docs: add notes`
- one file, `notes.md` ("# Notes / Existing work.")

So I can't make "a first commit" without either rewriting or throwing away that commit. I didn't want to do either without your say-so, because neither can easily be undone.

**Options:**

1. **Add the standards on top of the existing history (my recommendation).** I keep `cde5fd4` and copy in the standard files with source headers: `.gitignore`, `CONTRIBUTING.md`, `docs/DEVELOPMENT.md`, `.pre-commit-config.yaml`, `commitlint.config.mjs`, CI, Dependabot, the `CLAUDE.md` "Read first" line, and the `docs/agents/*` files. Then I install the hooks and make a second commit that passes them. Nothing is lost. The catch is that it's a small retrofit, which the standards leave out of scope, and it won't be the repo's first commit.
2. **Start fresh history.** You move or delete `.git` yourself, or tell me plainly to do it. I then `git init` on `main` and make a true first commit that includes `notes.md`. The old commit is gone.
3. **Use a different, empty folder** for the new project.

Two smaller things:
- The `new-project` skill (`skills/new-project/SKILL.md` in `dominicfarr/claude-skill-lab`) doesn't exist yet; it returns a 404. So I'd follow the steps in `PLAN.md` and `docs/DEVELOPMENT.md` by hand.
- Cloning the standards repo needed approval this session, so I'd copy each file through `gh api` instead.

Whichever option you pick, I won't create a GitHub repo or labels.
