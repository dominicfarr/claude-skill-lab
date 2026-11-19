# new-subdomain

Hosts a static site or a single file on a `domfarr.com` subdomain, backed by one CloudFormation stack (S3, CloudFront, ACM, Route 53).

**Trigger:** the skill just tells Claude to run the script directly — `skills/new-subdomain/scripts/subdomain.sh up <name> <path>` / `down <name>`.

**Inputs:** a subdomain name; a local path (a folder containing `index.html` for a site, or a single file).

**Outputs:** a live `https://<name>.domfarr.com`.

**Requires:** AWS CLI with the `domfarr` profile (override with `AWS_PROFILE`), `python3`, `openssl`, `dig`.

## Behavior

- A folder is hosted as a site: unknown paths fall back to `index.html`, so client-side routing works. A single file is hosted at every path, served with its own content type.
- `up` is idempotent — a no-op stack deploy when nothing changed, then upload, cache invalidation, and a content/certificate/DNS check.
- Refuses a name whose bucket or DNS records already exist from outside this script (e.g. the hand-built `care`, `coconut`, `organism`).
- A single file's stored object name is sanitized to `[a-zA-Z0-9._-]` (CloudFront's `DefaultRootObject` charset); the public URL is unaffected, since it's always just the bare subdomain.
- `down` asks for confirmation before deleting the stack; `--yes` skips the prompt.

## Evals

`evals/evals.json` holds the test cases.
