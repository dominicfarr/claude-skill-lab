## Agent skills

### Issue tracker

Issues and specs live as GitHub issues on `dominicfarr/claude-skill-lab`, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context layout: `GLOSSARY.md` and `docs/adr/` at the repo root (created lazily by domain-modeling when needed). See `docs/agents/domain.md`.

### Skill documentation

Every skill has its own `skills/<name>/README.md`, written as a short, structured, tell-not-show contract (no diagrams, no worked examples unless a fact alone is ambiguous) -- not duplicated into the root `README.md`. See `docs/agents/skill-readme.md` for the template, and follow it whenever a skill is created or changed.
