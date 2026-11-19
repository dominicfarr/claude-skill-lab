# Skill README convention

Every skill under `skills/<name>/` has its own `README.md`, written for a human skimming the repo — not for Claude (that's what `SKILL.md` is for). It's a **tell, not show** document: state the contract in short, declarative facts. No walkthroughs, no narrated examples, no diagrams, unless a behavior genuinely can't be stated as a fact (rare — if you reach for one, you're probably describing an implementation detail that belongs in `SKILL.md` instead).

Keep the whole file short enough to read in one scroll. If a section would need a worked example to make sense, that's usually a sign the behavior itself is too fiddly and should be simplified, not documented harder.

## Template

```markdown
# <skill-name>

<One or two sentences: what it does and who/what it's for.>

**Trigger:** `/skill-lab:<name> <args>` — or however it's actually invoked (note if `disable-model-invocation` is set, since that means it won't trigger from conversation alone).

**Inputs:** <bullet list of what it takes>

**Outputs:** <bullet list of what it produces>

**Requires:** <tools, auth, MCP connectors, env vars — or "nothing beyond the base install">

## Behavior

<Bullet list of the non-obvious rules a user or maintainer needs to know — things that would surprise someone, or that the skill enforces on purpose. State each as a fact, not a story. Leave out anything a reader could already guess from the name and the sections above.>

## Evals

<One line: where the test cases live and the exact command to run them, if there is one.>

## Limitations

<Optional. Only include real, current limitations — delete the section if there aren't any worth calling out.>
```

## Rules

- No mermaid diagrams, no "first X happens, then Y" narration, no multi-example galleries. One stated rule beats three examples that each illustrate the same rule.
- An example is allowed only when a fact alone would be ambiguous (e.g. an exact output format) — keep it to one line.
- Don't duplicate what's already a fact in `SKILL.md` or a script's own `--help`; link or name the file instead of re-explaining it.
- Keep the root `README.md` free of per-skill detail. It links to each skill's folder (which GitHub renders as that skill's `README.md`); it doesn't repeat the content.
