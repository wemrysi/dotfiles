---
name: beads-rust
description: Use when tracking implementation tasks, managing issues, or updating task status — replaces TodoWrite. Use for plan execution task lists, session start/end protocols, and any issue lifecycle management with the beads_rust (br/bd) CLI.
---

# Beads Rust — Task Tracking

`beads_rust` (`br`) is the issue tracker for this environment. Issues live in `.beads/` and are committed to git alongside code. Use it wherever you would otherwise reach for TodoWrite or a mental checklist.

## Initialization

Before using `br` in any repo, verify a workspace exists:

```bash
br where 2>/dev/null || echo "not initialized"
```

If not initialized, run `br init` in the **directory that contains the actual `.git` dir** — never in a worktree subdirectory:

```bash
# Find the correct init directory
if git rev-parse --is-bare-repository 2>/dev/null | grep -q true; then
  # Bare repo: the git dir itself is the root
  init_dir=$(cd "$(git rev-parse --git-common-dir)" && pwd)
else
  # Normal repo or worktree: parent of the common git dir
  init_dir=$(dirname "$(cd "$(git rev-parse --git-common-dir)" && pwd)")
fi

(cd "$init_dir" && br init)
```

This handles all three cases correctly:
- **Normal repo** (`/repo/.git`) → init in `/repo/`
- **Worktree** (`.git/worktrees/name`) → init in `/repo/` (the main repo root)
- **Bare repo** (`/repo.git/`) → init in `/repo.git/`

## Core Commands

```bash
# Find work
br ready                        # Open, unblocked, not deferred — start here
br list --status=open           # All open issues
br show <id>                    # Full details with dependencies
br search "keyword"             # Full-text search

# Create
br create --title="..." --description="..." --type=task --priority=2

# Lifecycle
br update <id> --status=in_progress
br close <id> --reason="Completed"
br close <id1> <id2>            # Close multiple at once

# Dependencies
br dep add <issue> <depends-on> # issue blocks on depends-on
br dep list <id>                # Show deps for an issue

# Sync
br sync --flush-only            # Export DB → JSONL (always do this before committing)
br sync --status                # Check sync state
```

## Task Tracking for Plan Execution

When executing an implementation plan, create one beads issue per task **before starting work**:

```bash
# Create issues for all tasks up front
br create --title="Task 1: <name>" --description="<what it does>" --type=task --priority=2
br create --title="Task 2: <name>" --description="<what it does>" --type=task --priority=2
# ... one per task

# Wire sequential dependencies so br ready surfaces work in order
br dep add <task-2-id> <task-1-id>   # task 2 depends on task 1
br dep add <task-3-id> <task-2-id>   # task 3 depends on task 2
```

Then follow the lifecycle as you work:

```bash
br update <id> --status=in_progress  # when starting a task
br close <id> --reason="Completed"   # when reviews pass
```

## Reference

**Priority** (use numbers, not words):

| Number | Meaning |
|--------|---------|
| 0 | critical |
| 1 | high |
| 2 | medium |
| 3 | low |
| 4 | backlog |

**Types:** `task`, `bug`, `feature`, `epic`, `chore`, `docs`, `question`

**Statuses:** `open`, `in_progress`, `deferred`, `closed`

## Multi-Repo Workflows

`br` discovers its database by walking up from the current working directory until it finds a `.beads/` directory. When a plan spans multiple repos, **create issues in the repo they belong to** by running `br` from that repo:

```bash
# Issues for repo-a work go in repo-a's DB
(cd /path/to/repo-a && br create --title="Task: ..." ...)

# Issues for repo-b work go in repo-b's DB
(cd /path/to/repo-b && br create --title="Task: ..." ...)
```

Alternatively, use `--db` to target a specific database without changing directory:

```bash
br --db /path/to/repo/.beads/beads.db create --title="..." ...
```

Never create issues for repo A while sitting in repo B's directory — they will land in the wrong database.

## Session Protocol

Run this before ending any session:

```bash
git status                  # Review what changed
git add <files>             # Stage code changes
br sync --flush-only        # Export beads state to JSONL
git commit -m "..."
git push
```

`br sync --flush-only` must run **before** the git commit so the JSONL is up to date when committed.

## Best Practices

- Run `br ready` at session start — it shows only actionable work
- Create issues before work begins, not after
- Update status transitions promptly (`open` → `in_progress` → `closed`)
- Use `--reason` on `br close` to leave a useful audit trail
- Prefer `br dep add` over manual ordering — it lets `br ready` surface work automatically
- Always sync before ending a session; uncommitted beads state is lost on next import
