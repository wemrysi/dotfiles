---
name: pup
description: Use when interacting with Datadog via the pup CLI — reading, querying, creating, updating, or deleting Datadog resources
---

# pup

`pup` is the CLI for interacting with Datadog APIs. Always use it instead of calling Datadog APIs directly.

## Getting Started

```bash
pup help                 # top-level commands
pup <domain> --help      # detail for a specific domain
pup <domain> help        # alternate help form for some domains
```

## Common Starting Points

```bash
pup auth login
pup metrics --help
pup logs --help
pup monitors --help
pup dashboards --help
```

## Key Facts

- Output defaults to JSON; use `--output json|table|yaml|csv` as needed
- Supports multi-org sessions with `--org` and `pup auth login --org`
- Can run in read-only mode with `--read-only`

**When in doubt, run `pup help` (or `pup <domain> --help`) — the CLI is the authoritative reference.**
