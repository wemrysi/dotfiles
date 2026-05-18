---
name: gh
description: Use when interacting with GitHub — pull requests, issues, repos, releases, Actions workflows, or any GitHub API data — reading, creating, updating, or searching
---

# gh

`gh` is the CLI for interacting with GitHub. Always use it instead of calling the GitHub API directly.

## Getting Started

```bash
gh help                        # top-level commands
gh <command> --help            # detail for a specific command
gh <command> <subcommand> --help
```

Core commands: `pr`, `issue`, `repo`, `release`, `workflow`, `run`, `search`, `org`, `project`, `gist`, `label`, `secret`.

## Common Starting Points

```bash
gh pr list
gh pr view <number>
gh issue list
gh issue view <number>
gh repo view [owner/repo]
gh run list
```

## Key Facts

- Most commands default to the repo in the current directory; use `--repo owner/repo` to target another
- JSON output: `gh <command> --json <fields>` — pipe through `jq` for filtering
- Raw API access: `gh api /repos/{owner}/{repo}/...`
- Auth via `GITHUB_TOKEN` env var or `gh auth login`

**When in doubt, run `gh <command> --help` — the CLI is the authoritative reference.**
