# Claude Skills Monorepo

A collection of custom Claude Code skills — each self-contained with its definition and eval history.

---

## Skills

| Skill | Slash Command | Description |
|---|---|---|
| [gmail-label-reader](skills/gmail-label-reader/) | `/skill-lab:gmail-label-reader` | List Gmail labels and browse email titles by label |

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
    └── evals/
        ├── evals.json            # Test cases and assertions
        └── runs/                 # Captured eval outputs (auto-generated)
```

1. Write `skills/your-skill-name/SKILL.md`
2. Add test cases to `skills/your-skill-name/evals/evals.json`
3. Add a row to the Skills table above
4. Run `scripts/test-plugin-install.sh` to confirm the plugin loads it

New skill directories are picked up by the plugin automatically; no manifest change is needed.

---

## File Tree

```
.
├── skills/
│   └── gmail-label-reader/
│       ├── SKILL.md                       # Canonical skill definition
│       └── evals/
│           ├── evals.json                 # Test prompts and pass/fail assertions
│           └── runs/                      # Eval run history (snapshot baselines)
│               ├── iteration-1/
│               │   └── eval-1/
│               │       ├── eval_metadata.json
│               │       └── with_skill/outputs/summary.md
│               └── iteration-2/
│                   └── eval-1/
│                       ├── eval_metadata.json
│                       ├── with_skill/outputs/output.md
│                       └── without_skill/outputs/output.md
│
├── .claude-plugin/
│   ├── plugin.json                        # Plugin manifest (skill-lab)
│   └── marketplace.json                   # Marketplace manifest listing the plugin
│
├── scripts/
│   └── test-plugin-install.sh             # Install check
│
├── .devcontainer/
│   └── devcontainer.json                  # Dev container configuration
├── .gitignore
└── README.md
```

---

## Eval Framework

Each skill has a structured eval that compares **with-skill** runs (Claude following `SKILL.md`) against **without-skill** baseline runs (Claude answering the same prompt unaided).

```
evals/
├── evals.json          # Test prompts + assertions (authored)
└── runs/               # Captured outputs per iteration (generated)
    ├── iteration-1/
    └── iteration-2/
```

Each eval defines a prompt and a set of pass/fail assertions. Run outputs are captured as markdown snapshots under `runs/` and committed as baselines for regression comparison.

---

## gmail-label-reader

### Architecture

### Sequence

```mermaid
sequenceDiagram
    actor User
    participant Claude as Claude Code
    participant Skill as Skill Instructions
    participant MCP as Gmail MCP
    participant Gmail as Gmail API

    User->>Claude: /skill-lab:gmail-label-reader

    Claude->>Skill: load skill instructions
    Skill-->>Claude: 4-step workflow

    Note over Claude: Step 1 — Auth check
    Claude->>MCP: probe for Gmail tools
    alt tools unavailable
        Claude-->>User: "Please authenticate via /mcp"
        User->>Claude: confirms auth complete
    end

    Note over Claude: Step 2 — List labels
    Claude->>MCP: list_labels()
    MCP->>Gmail: GET /labels (OAuth)
    Gmail-->>MCP: label list
    MCP-->>Claude: labels JSON
    Claude-->>User: numbered label list

    User->>Claude: picks a label (number or name)

    Note over Claude: Step 3 — Fetch threads
    Claude->>MCP: search_threads(label:<name>, max=50)
    MCP->>Gmail: GET /threads?q=label:... (OAuth)
    Gmail-->>MCP: thread list
    MCP-->>Claude: threads JSON

    opt sender/subject/date fields missing
        Claude->>MCP: get_thread(id, METADATA format)
        MCP->>Gmail: GET /threads/:id
        Gmail-->>MCP: thread headers
        MCP-->>Claude: headers only
    end

    Note over Claude: Step 4 — Present results
    Claude-->>User: numbered list\n(sender · subject · date)\nno body content
```

### Privacy

Reads **headers only** (sender, subject, date). Message bodies are never fetched or processed. Authentication is via OAuth 2.0 through the claude.ai Gmail MCP connector — no credentials are stored in this repository.
