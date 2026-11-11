# Claude Skills Monorepo

A collection of custom Claude Code skills — each self-contained with its definition and eval history.

---

## Skills

| Skill | Slash Command | Description |
|---|---|---|
| [gmail-label-reader](skills/gmail-label-reader/) | `/skill-lab:gmail-label-reader` | List Gmail labels and browse email titles by label |
| [new-project](skills/new-project/) | `/skill-lab:new-project` | Turn an empty folder into a project with Dom's standards, up to a gated first commit |
| [new-subdomain](skills/new-subdomain/) | `/skill-lab:new-subdomain` | Host a static site or a single file on a domfarr.com subdomain (CloudFormation: S3, CloudFront, ACM, Route 53) |

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
│   ├── new-project/
│   │   ├── SKILL.md
│   │   ├── scripts/                       # check-safe.sh, copy-standards.sh
│   │   └── evals/                         # evals.json, run-evals.sh, check.sh, gh-guard/, runs/
│   ├── new-subdomain/
│   │   ├── SKILL.md
│   │   ├── scripts/                       # subdomain.sh, subdomain.yaml (CloudFormation)
│   │   └── evals/evals.json
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

---

## new-project

Run `/skill-lab:new-project [repo-name]` in an empty folder, or one holding only an idea note. It refuses a folder with git history (or inside another repo) and a repo name `dominicfarr` already has, then: `git init` on `main`, copies the standard files and base gates from `dominicfarr/dev-standards`, sets up the Matt Pocock skills (GitHub tracker, default triage labels, single-context), writes `CLAUDE.md` with the "Read first" line and a README with *Development setup*, installs the `pre-commit` and `commit-msg` hooks, and makes a first commit that passes them. Only then does it create the public `dominicfarr/<repo-name>` repo, push `main`, create the missing triage labels and watch the first CI run. Pass `--local-only` to stop after the first commit and keep the repo local.

Needs `gh` (logged in), `uv`, pre-commit and the `mattpocock-skills` plugin.

### What it copies

From the standards repo's default branch, through `gh api`, all read at one commit: `.gitignore`, `CONTRIBUTING.md`, `docs/DEVELOPMENT.md`, `.pre-commit-config.yaml`, `commitlint.config.mjs`, `.github/workflows/ci.yml` and `.github/dependabot.yml`. Hook fragments and Sonar templates come later, through the stack and Sonar tickets. The list lives in `skills/new-project/scripts/copy-standards.sh`.

Each copy's first line is a **source header** naming that commit, in the file's own comment syntax: `# from dominicfarr/dev-standards@<sha>` (YAML, `.gitignore`), `<!-- … -->` (Markdown), `// …` (`.mjs`). Every file in the set can carry a comment on line 1. The script refuses a file type with no comment syntax (such as JSON) instead of copying it without a header, so adding one means choosing its fallback first.

### Evals

```sh
skills/new-project/evals/run-evals.sh <iteration>               # every eval, with and without the skill
skills/new-project/evals/run-evals.sh <iteration> with_skill 1  # one eval, one variant
```

Each eval runs `claude -p` in a fresh scratch folder under `$TMPDIR`, with a scoped tool allowlist, and `check.sh` grades the folder from outside (and, for the refuse-history eval, checks the reply quotes `check-safe.sh`'s refusal). No eval can create a GitHub repo: GitHub writes and `git push` are denied, a `gh` guard first on PATH refuses them too, the skill runs with `--local-only`, and `check.sh` confirms `dominicfarr/<folder>` doesn't exist afterwards. Results land in `evals/runs/iteration-<n>/`.

---

## new-subdomain

A plain command; the skill only tells Claude to run it. From a shell:

```sh
skills/new-subdomain/scripts/subdomain.sh up <name> <path>    # create, or update and re-upload
skills/new-subdomain/scripts/subdomain.sh down <name>         # delete everything (asks to confirm; --yes skips)
```

A folder with `index.html` is hosted as a **site** (unknown paths serve `index.html`, so client-side routes work). A single file is hosted on its own (every path serves that file with its own content type, so a GIF or PDF renders directly in the browser).

### Examples

```sh
# A built site: dist/ has index.html at its top
skills/new-subdomain/scripts/subdomain.sh up blog ~/Projects/blog/dist
# -> https://blog.domfarr.com

# One file, served at / and every other path
skills/new-subdomain/scripts/subdomain.sh up banner ./banner.gif

# A file name with spaces: pass it as it is, quoted
skills/new-subdomain/scripts/subdomain.sh up care-cost "dist/Cheltenham Care Costs.html"
# -> stored as Cheltenham-Care-Costs.html, served at https://care-cost.domfarr.com

# Change the site and run up again: the stack is left as it is and the files are re-uploaded
skills/new-subdomain/scripts/subdomain.sh up blog ~/Projects/blog/dist

# Remove it all: stack, bucket, certificate and DNS records
skills/new-subdomain/scripts/subdomain.sh down blog --yes
```

### File names with spaces

A single file is stored under a cleaned-up copy of its name. Each run of characters other than letters, digits, `.`, `_` and `-` becomes one dash, and leading dashes are dropped. A name that ends up empty or starting with `.` is stored as `file`. The URL is the bare subdomain either way, so the stored name never shows. The file you pass is left as it is.

| You pass | Stored as |
|---|---|
| `Cheltenham Care Costs.html` | `Cheltenham-Care-Costs.html` |
| `Q3 report (final).pdf` | `Q3-report-final-.pdf` |
| `banner.gif` | `banner.gif` |

**Why:** the stored name becomes the CloudFront distribution's `DefaultRootObject`, the object served at `/`. CloudFront accepts only `a-z A-Z 0-9 _ - . * $ / ~ " ' &` there, so a name with a space fails the whole stack deploy with `The parameter DefaultRootObject can only contain these characters`. The script keeps to a stricter set because the same name is also an S3 key and the error page path. Eval 4 (`file-name-with-spaces`) covers this case.

Each subdomain is one CloudFormation stack, `subdomain-<name>`, defined in `subdomain.yaml`: a private S3 bucket, a certificate validated through Route 53, a CloudFront distribution with its own origin access control, and A/AAAA alias records. `up` deploys the stack (a no-op when nothing changed), uploads, invalidates the cache, then checks the content, certificate and public DNS. It refuses names with a bucket or DNS records it didn't create, so the hand-built `care`, `coconut` and `organism` are left alone.

Needs the AWS CLI with the `domfarr` profile (override with `AWS_PROFILE`), plus `python3`, `openssl` and `dig`.
