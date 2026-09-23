# Upstream: obra/superpowers

These skills are a vendored copy of the `skills/` directory from
<https://github.com/obra/superpowers>, plus a few local customizations.
Pi doesn't manage them; they're plain files in this dotfiles repo.

To update, follow [UPDATING.md](UPDATING.md).

## Current base

| Field   | Value |
| ------- | ----- |
| Repo    | https://github.com/obra/superpowers |
| Tag     | `v6.4.1` |
| Commit  | `5bf4e78011075bcfc0dc295f0724994cd123ee71` |
| Date    | 2026-09-18 (upstream release) |
| Updated | 2026-09-23 |
| Source  | `skills/` in upstream → this directory (`pi/.pi/agent/skills/superpowers/`) |

This directory should match upstream `skills/` at that commit exactly, except
for the files listed below and these two notes (`UPSTREAM.md`, `UPDATING.md`).

## Local customizations

Keep this list in sync. If a change shows up in the diff against upstream and
isn't listed here, it was made without being recorded; add it or drop it.

### 1. Plans and specs live in the planning repo, not in the project repo

Upstream saves to `docs/superpowers/{specs,plans}/` inside the project repo.
Locally they go to `~/work/precog/planning/<repo-name>/{specs,plans}/`, and
`<repo-name>` is derived so it's the same from any worktree:

```bash
COMMON_ABS=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
REPO_NAME=$(basename "$(dirname "$COMMON_ABS")")
REPO_NAME=${REPO_NAME%.git}
```

Files touched:
- `brainstorming/SKILL.md`: checklist step 6, the **Documentation** section
  (path, `REPO_NAME` snippet, `mkdir -p`, commit happens in the planning repo),
  and the **User Review Gate** message.
- `brainstorming/spec-document-reviewer-prompt.md`: the "Dispatch after" path.
- `writing-plans/SKILL.md`: **Save plans to** (path, `REPO_NAME` snippet,
  `mkdir -p`; dropped the "user preferences override" line) and both
  "Plan complete and saved to ..." handoff messages.

Left alone on purpose: the illustrative `docs/superpowers/plans/...` paths in
the examples in `executing-plans`, `subagent-driven-development`, and
`requesting-code-review`.

### 2. Task tracking ("todos") = beads-rust (`br`)

Upstream skills talk about a generic "todo" (create / mark in_progress / mark
complete) and map it to each harness's tool in
`using-superpowers/references/<harness>-tools.md`. Locally the Pi mapping
points at beads-rust.

Files touched:
- `using-superpowers/references/pi-tools.md`: the "Task tracking" table row and
  the whole **Task lists** section.

Related change outside this directory (not vendored, no merge needed):
- `pi/.pi/agent/AGENTS.md`: a "Task tracking (superpowers)" section, so the
  mapping is in context even when a skill is loaded without `using-superpowers`.

Design note: don't edit the "todo" wording inside individual skills. Keeping
the mapping in `pi-tools.md` is what keeps updates nearly conflict-free.
Before v6.4.1 (base v5.1.0) this customization was spread across ~10 `TodoWrite`
mentions in 5 skills, and every one of them conflicted on update.

## History

| Updated    | Base               | Notes |
| ---------- | ------------------ | ----- |
| 2026-05-18 | v5.1.0 (`f2cbfbe`) | Initial import. Customizations: planning-repo paths, `TodoWrite` → beads edited inline in each skill. |
| 2026-09-23 | v6.4.1 (`5bf4e78`) | Updated with the three-way merge in UPDATING.md. Todo mapping moved to `pi-tools.md` + `AGENTS.md`. Upstream rewrote executing-plans/SDD (ledger + scripts) and added `diagnosing-superpowers`. |
