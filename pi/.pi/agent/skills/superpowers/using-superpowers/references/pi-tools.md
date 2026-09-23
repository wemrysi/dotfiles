# Pi Tool Mapping

Skills speak in actions ("dispatch a subagent", "create a todo", "read a file"). On Pi these resolve to the tools below.

| Action skills request | Pi equivalent |
| --- | --- |
| Dispatch a subagent (`Subagent (general-purpose):` template) | Use an installed subagent tool such as `subagent` from `pi-subagents` if available |
| Task tracking ("create a todo", "mark in_progress", "mark complete") | beads-rust (`br`) — load the `beads-rust` skill. Create a todo = `br create`; in_progress = `br update <id> --status=in_progress`; complete = `br close <id> --reason="Completed"` |

## Subagents

Pi core does not ship a standard subagent tool. The `pi-subagents` package is a strong optional companion and provides a `subagent` tool with single-agent, chain, parallel, async, forked-context, and resume/status workflows. If no subagent tool is available, do not fabricate `Task` calls; execute sequentially in the current session or explain that the optional subagent capability is not installed.

## Task lists

In this environment, task tracking is **beads-rust (`br`)**, not a todo tool or `TODO.md`. Whenever a skill says to create a todo, mark one in_progress, or mark one complete, use the equivalent `br` command, and load the `beads-rust` skill for initialization, dependencies, and sync rules.

- "Create a todo per task/item" → one `br create --title="..." --type=task` per task or item. For plan tasks, title them `Task <N>: <name>` and wire sequential dependencies with `br dep add`.
- "Mark the todo in_progress" → `br update <id> --status=in_progress`
- "Mark the todo complete" → `br close <id> --reason="Completed"`

The executing-plans / subagent-driven-development **ledger** (`<workspace>/progress.md`) is separate and still required: beads issues are the live task view, the ledger is the record. Older Superpowers docs may refer to `TodoWrite`; treat that as beads-rust too.
