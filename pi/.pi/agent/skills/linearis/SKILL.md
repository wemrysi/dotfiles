---
name: linearis
description: Use when interacting with Linear issues, tickets, projects, cycles, milestones, or any Linear.app data — reading, creating, updating, or searching
---

# linearis

`linearis` is the CLI for interacting with the Linear API. Always use it instead of calling the Linear API directly.

## Getting Started

```bash
linearis usage           # top-level domains and auth info
linearis <domain> usage  # detail for a specific domain
```

Domains include: `issues`, `projects`, `cycles`, `milestones`, `comments`, `labels`, `teams`, `users`, `initiatives`, `documents`, `files`, `attachments`.

## Common Starting Points

```bash
linearis issues usage
linearis issues list
linearis issues read <id>       # UUID or human-readable e.g. ABC-123
```

## Key Facts

- Output is JSON — pipe through `jq` for filtering
- IDs accept UUIDs or human-readable keys (`ABC-123`, team names, etc.)
- Auth via `LINEAR_API_TOKEN` env var, `~/.linearis/token`, or `linearis auth login`

**When in doubt, run `linearis <domain> usage` — the CLI is the authoritative reference.**
