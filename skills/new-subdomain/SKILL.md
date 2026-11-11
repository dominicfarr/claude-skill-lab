---
name: new-subdomain
description: Host a static site or a single file on a domfarr.com subdomain, or take one down. Use when asked to put a built site (a dist folder) or one file (a GIF, a PDF) on <name>.domfarr.com, update it, or remove it.
argument-hint: "up|down <name> [path]"
---

# new-subdomain

`scripts/subdomain.sh` (beside this file) does all the work through a CloudFormation stack: bucket, certificate, CloudFront, DNS, upload and checks. Run it; there is nothing to decide beyond its arguments.

```sh
<skill-dir>/scripts/subdomain.sh up <name> <path>    # create, or update and re-upload
<skill-dir>/scripts/subdomain.sh down <name> --yes   # delete everything
```

- **Name:** the label, so `care` gives `care.domfarr.com`. Ask Dom if it's missing.
- **Path:** a folder with `index.html` at its top (a site), or a single file (served at every path). If Dom names a project, build it first and pass the build output, such as `dist/`.
- **`down`** destroys the site. Run it only when Dom has asked for that subdomain to be removed.

A first `up` takes several minutes while the certificate and distribution deploy; run it in the background. The script refuses names it didn't create (`care`, `coconut` and `organism` were built by hand), and exits non-zero on any failed check.

## Report

Relay the script's last lines: the URL and the three checks (content, certificate, DNS). On a refusal or failure, show its message and stop.
