---
name: precog-singleton
description: Use when building, running, or scripting against the Precog "singleton" local-dev server (all backend services in one JVM) — starting instances, isolating multiple instances, loading source kinds (RSKs), or calling its HTTP API for sources/destinations/pipelines
---

# Precog Singleton

The **singleton** runs all Precog backend services in one JVM for local dev/integration
testing, replacing the Kubernetes-based production deployment. It exposes an HTTP API
(default port 8080) and uses `DummyAuth` — no `Authorization` header needed; all requests
are attributed to a fixed dev tenant.

This skill covers: which instance/worktree to use, how to configure credentials without
hardcoding them, how to run/isolate instances, how to make sure source kinds (RSKs) exist
before you try to use them, and where to find full API details.

Reference files (load as needed — don't front-load everything):

- `instance-setup.md` — build/run/isolate a singleton instance, process-management gotchas
- `source-kinds.md` — checking for and loading RSKs (source kind definitions)
- `api-reference.md` — HTTP endpoint highlights and where to find the full spec
- `scripts/` — small helper scripts that make the fiddly parts (health-wait, backgrounding,
  RSK insertion, container discovery) deterministic instead of re-derived by hand each time

---

## Step 1: Which instance to use?

**Convention:** look for a singleton-buildable worktree in the current working directory
(walk up from cwd; look for a `build.sbt` whose modules include `singleton`, e.g. a line
like `name := "singleton"`, or a `modules/singleton` directory). This is the common case
during active development of the services repo.

- **If found**: use that worktree.
- **If not found**: use the default worktree at `~/work/precog/services/main`.
- **Either way**: if the user has already told you which worktree/branch to use, or a
  running instance/port to talk to, honor that instead of guessing. If it's ambiguous
  (e.g. multiple candidate worktrees, or unclear whether to build fresh or reuse a running
  instance), ask.

Don't assume a particular branch, port, or mongo-db name beyond this — those are per-task
choices (see `instance-setup.md` for isolation knobs when running more than one instance).

## Step 2: Credentials and per-task configuration

The singleton itself needs no real credentials (auth is bypassed), but the *sources and
destinations you create through it* usually do (API tokens, Snowflake keys, S3 buckets,
etc.). Never hardcode credentials into this skill or into code — they belong in a
per-task/per-repo config file that isn't part of the skill.

**Convention:** look for `singleton.config.md` in the current working directory (or the
path in `$SINGLETON_SKILL_CONFIG` if set). It's a plain Markdown file, not committed to
version control, with one `##` section per concern and `key = value` bullets, e.g.:

```markdown
## Singleton Environment

- OMP_NUM_THREADS = 4

## Intercom Source Config

- Connector Name = Test
- Access Token = <token>
- API Region = api.intercom.io

## Snowflake Destination Config

- Account URL = https://<account>.snowflakecomputing.com
- Username = ...
- Private Key = ./snowflake-key.pem
- Database = ...
- Warehouse = ...
```

Section names and keys are free-form — match whatever the RSK's `configSchema` or
destination's config actually needs. If the file doesn't exist and you need credentials
for a source/destination, **ask the user** rather than inventing values or reusing values
you recall from elsewhere. If the user provides credentials inline in chat, offer to save
them into `singleton.config.md` for reuse rather than only using them ephemerally.

## Step 3: Make sure the source kind you need is actually loaded

A fresh singleton instance (new `--mongo-db`, or first use of a worktree) often has **no
RSKs (source kinds) loaded at all**. Before creating a source:

1. Check what's loaded: `GET /source-kinds` (see `scripts/list-source-kinds.sh`).
2. If the one you need is missing:
   - If the user named a specific connector, load that one.
   - If they didn't and none are loaded, ask which one to use (don't silently pick one).
3. Load it from the local checkout of RSK definitions at
   `~/work/precog/web-source-kinds/modules/core/src/main/resources/rootstock-kinds/`
   (filenames like `intercom-5.0.0.yml`, but match by the YAML's `id:` field, not the
   filename — see `scripts/find-rsk-yaml.sh`) unless the user points you at a different
   source/path. See `source-kinds.md` for the insertion procedure and gotchas — use
   `scripts/insert-source-kind.sh` rather than re-deriving the mongosh/jq pipeline by hand.

## Step 4: Run it, then use the API

See `instance-setup.md` for build/run steps, required infra, and multi-instance isolation.
See `api-reference.md` for endpoint shapes; see full OpenAPI specs at
`~/work/precog/api-specs/reference/` (`public-http-api.yaml`, `admin-http-api.yaml`,
`metadata-http-api.yaml`, plus `schemas/`) for anything not covered here.

## Prefer scripts over hand-rolled one-liners

Several parts of working with the singleton are fiddly to get right free-hand every time
(waiting for readiness, backgrounding a JVM without losing it, finding the right Mongo
container, building a complete RSK document). Where a script exists in `scripts/`, use it
instead of reconstructing the equivalent `curl`/`mongosh`/`jq` pipeline from scratch — it's
faster and less error-prone. If you find yourself repeating a new multi-step dance that
isn't covered by an existing script, consider proposing it as an addition to this skill
(or, if it's really a product gap, as an improvement to the singleton itself — e.g. a
`--load-source-kinds-dir` startup flag would remove the need for manual RSK insertion
entirely) rather than just leaving it as tribal knowledge in a handoff doc.
