# Claude Skills Monorepo

A collection of custom Claude Code skills — each self-contained with its definition, its own README, and its eval history.

---

## Skills

| Skill | Slash Command | Description |
|---|---|---|
| [gmail-label-reader](skills/gmail-label-reader/) | `/skill-lab:gmail-label-reader` | List Gmail labels and browse email titles by label |
| [new-project](skills/new-project/) | `/skill-lab:new-project` | Turn an empty folder into a project with Dom's standards, up to a gated first commit |
| [new-subdomain](skills/new-subdomain/) | `/skill-lab:new-subdomain` | Host a static site or a single file on a domfarr.com subdomain (CloudFormation: S3, CloudFront, ACM, Route 53) |
| [story-map](skills/story-map/) | `/skill-lab:story-map` | Turn an idea or GitHub issue into a User Story Map, slice a walking skeleton, and write Gherkin BDD specs for it |

Each skill's own `README.md` (linked above) has its contract: inputs, outputs, dependencies, and the non-obvious behavior rules. This file only covers what's shared across all of them.

---

## Install

The repo is a Claude Code plugin marketplace (`skill-lab`) that lists one plugin (`skill-lab`) containing every skill under `skills/`.

From a shell:

```sh
claude plugin marketplace add dominicfarr/claude-skill-lab
claude plugin install skill-lab@skill-lab
```

Or inside a Claude Code session:

```
/plugin marketplace add dominicfarr/claude-skill-lab
/plugin install skill-lab@skill-lab
```

On Claude Code 2.1.275 or later you can do it in one step (or from a shell: `claude plugin install skill-lab --marketplace dominicfarr/claude-skill-lab`):

```
/plugin install skill-lab --marketplace dominicfarr/claude-skill-lab
```

Run `/reload-plugins` (or start a new session) and the skills are available. Claude picks them up from what you ask, or you can invoke one directly, e.g. `/skill-lab:gmail-label-reader`. If a skill requires external authentication (e.g. Gmail), Claude will prompt you on first use.

To pick up new skills later: `claude plugin marketplace update skill-lab`, then `claude plugin update skill-lab@skill-lab`.

### Check the install

`scripts/test-plugin-install.sh` validates the manifests, adds the marketplace in a throwaway config dir, installs the plugin, and confirms every skill in `skills/` loaded. Pass `dominicfarr/claude-skill-lab` to test the published repo instead of your working copy.

---

## Adding a New Skill

```
skills/
└── your-skill-name/
    ├── SKILL.md                  # Skill definition (source of truth)
    ├── README.md                 # Human-facing contract -- see docs/agents/skill-readme.md
    └── evals/
        ├── evals.json            # Test cases and assertions
        └── runs/                 # Captured eval outputs (auto-generated)
```

1. Write `skills/your-skill-name/SKILL.md`
2. Write `skills/your-skill-name/README.md` following `docs/agents/skill-readme.md`'s template
3. Add test cases to `skills/your-skill-name/evals/evals.json`
4. Add a row to the Skills table above
5. Run `scripts/test-plugin-install.sh` to confirm the plugin loads it

New skill directories are picked up by the plugin automatically; no manifest change is needed.

---

## Eval Framework

Each skill has a structured eval that compares **with-skill** runs (Claude following `SKILL.md`) against **without-skill** baseline runs (Claude answering the same prompt unaided).

```
skills/<name>/evals/
├── evals.json          # Test prompts + assertions (authored)
└── runs/               # Captured outputs per iteration (generated)
    ├── iteration-1/
    └── iteration-2/
```

Each eval defines a prompt and a set of pass/fail assertions, graded per run and aggregated into a `benchmark.json`/`benchmark.md` pair comparing the two configurations. Run outputs are committed as baselines for regression comparison. See each skill's own README for how to run its evals.

---

## Repo layout

```
.
├── skills/<name>/
│   ├── SKILL.md       # Skill definition
│   ├── README.md      # Human-facing contract
│   ├── scripts/        # Executable helpers, if any
│   └── evals/          # evals.json + runs/
├── docs/agents/        # Conventions Claude follows when working in this repo
├── .claude-plugin/      # Plugin + marketplace manifests
├── scripts/             # Repo-level scripts (e.g. test-plugin-install.sh)
└── .devcontainer/
```
