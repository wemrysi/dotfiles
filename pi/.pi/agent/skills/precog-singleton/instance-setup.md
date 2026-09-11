# Instance Setup: Build, Run, Isolate

## Required infrastructure

The singleton depends on external services normally started via `docker compose up -d`
(or `podman compose up -d`) from the services worktree root:

| Service | Default port | Notes |
|---|---|---|
| MongoDB | 27017 | Replica set `rs0` required (needed for change streams/transactions). DB: `precog-dev` by default. |
| Redis | 6379 | |
| MinIO (S3) | 9000 / 9001 | Console at 9001. Default creds `minioadmin`/`minioadmin`. |
| web-microservice | 3010 | Needed for OAuth interactive-auth flows. Often shows "unhealthy" in `docker compose ps` but still works — check `docker logs <container>_precog-web-microservice_1` if OAuth actually fails. |

Shared infra (one `docker compose up -d`) is fine even when running multiple singleton
instances from different worktrees — you don't need a separate compose stack per instance.

## Build

```bash
cd <worktree>
sbt --client bloopInstall   # only needed after .versions.json changes or fresh checkout
bloop compile singleton
```

**Gotcha:** after changing `.versions.json` (e.g. pointing at a locally-published library),
bloop configs go stale and reference a nonexistent jar — symptom is `not found: type Foo`
for types that clearly exist. Re-run `bloopInstall` whenever dependencies change.

**Gotcha:** locally-published versions with a hash suffix (e.g. `1.1.4-ba949dd`) can
occasionally lose Coursier's conflict resolution to the GA release (`1.1.4`) — Coursier
treats the hash suffix as a semver pre-release, so the GA version wins. Symptom at runtime:
`NoSuchMethodError` for a method that exists in the feature jar but not the GA one. This is
not the common case — bloop usually resolves these correctly. It also happens between two
hash-suffixed local versions (e.g. two different local publishes of the same artifact),
where Coursier compares the suffixes lexicographically rather than by publish time, so an
older local publish can beat a newer one. If you do hit it, the fix is to add the local
version to `dependencyOverrides`. Prefer adding it to a settings scope that every dependent
module inherits (e.g. the shared `commonSettings` `Seq` applied across all projects, if one
exists) rather than only the module that declares the direct dependency — `dependencyOverrides`
is resolved per-project in sbt, so setting it only on the library module (e.g. `core`) will
not affect a downstream module (e.g. `singleton`) that depends on it, since `singleton`
resolves its own classpath independently. Do **not** use a separate `local.sbt`/global
override file — that's been observed not to take effect.

**Gotcha:** after editing `build.sbt` (e.g. adding/changing `dependencyOverrides` or any
other setting) an already-connected `sbt --client` session will keep using its previously
loaded build definition — running `bloopInstall` again in that session can silently
regenerate `.bloop/*.json` from the **stale** in-memory settings, so the wrong jar keeps
showing up even though the `build.sbt` change looks correct on disk. Always run
`sbt --client reload` immediately after any `build.sbt` edit, before the next
`bloopInstall`. After `bloopInstall`, verify the fix actually landed on the classpath
before recompiling or rerunning anything expensive:
```bash
grep -o '"[^"]*<artifact-name>[^"]*"' .bloop/<module>.json | sort -u
```
Only fall back to manually patching the generated `.bloop/*.json` to point at the local jar
path if the `dependencyOverrides` fix genuinely doesn't resolve it after a `reload` — that
patch doesn't survive the next `bloopInstall` and should be a last resort, not routine
practice.

## Run

```bash
bloop run singleton --main precog.service.singleton.Main -- [options] [service...]
```

Positional service names select a subset (omit all to run everything): `server`,
`scheduler`, `notification`, `credential-refresher`, `pipeline-load`, `dataset-discovery`,
`semantic-model-generation`. For plain endpoint testing, `server` alone is fastest. For
pipeline/load testing you typically need `server pipeline-load scheduler` at minimum, and
`dataset-discovery` if you rely on automatic dataset discovery.

### Key CLI options

| Option | Default | Isolate per instance? |
|---|---|---|
| `-p`/`--port` | 8080 | **yes** |
| `--mongo-uri` | `mongodb://localhost:27017` | |
| `--mongo-db` | `precog-dev` | **yes** |
| `--redis-uri` | `redis://localhost:6379` | |
| `--s3-endpoint` | `http://localhost:9000` (local MinIO) | |
| `--s3-access-key` / `--s3-secret-key` | `minioadmin` / `minioadmin` | |
| `--s3-bucket` | `precog-singleton` | |
| `--s3-path-prefix` | auto (username+hostname) | **yes**, if sharing a bucket across instances |
| `--staged-data-dir` | `~/.cache/precog/staged-data` | **yes** |
| `--local-dest-dir` | `~/.cache/precog/local-dest` | |
| `--staged-data-max-age` | `13 days` | |
| `--no-mongo-admin` | off | skip Mongo index management |
| `--tenant-id` | `dev-tenant` | dev-auth-bypass tenant |
| `--semantic-model-generator-image` + `--gcp-credentials-file` | none | must be given together or not at all |
| `--view-blends` | off | enable blended view creation |

Only change what you need to. For a single instance, defaults are fine. For **multiple
concurrent instances** (e.g. comparing two branches), give each a distinct `--port`,
`--mongo-db`, `--s3-path-prefix`, and `--staged-data-dir` at minimum.

Required env var: `OMP_NUM_THREADS` (e.g. `4`) — put this in `singleton.config.md` under
a "Singleton Environment" section (see main SKILL.md) rather than hardcoding a value here.

## Wait for readiness

First boot loads DJL embedding models (~400 MB download on a cold `~/.djl.ai` cache) — can
take 1–5 minutes. Poll instead of assuming a fixed sleep:

```bash
until curl -sf http://localhost:$PORT/ping; do sleep 1; done && echo Ready
```

Or use `scripts/wait-for-ready.sh $PORT`.

## Running in the background without losing the process

The bash tool's shell exits after each command, which kills unmanaged background jobs.
When you background a long-running singleton:

```bash
LOG=/tmp/singleton-<label>.log
bloop run singleton -- <args> > "$LOG" 2>&1 &
BGPID=$!; disown $BGPID
echo "Launched PID $BGPID, logging to $LOG"
```

Prefer `scripts/run-singleton.sh` (handles the log file, `disown`, and readiness wait
together) over reconstructing this by hand.

**Do not** kill it with `pkill -f "singleton.Main"` — that pattern can match the very shell
command you're running to do the killing, taking down your own shell. Find the JVM PID
specifically:

```bash
JVM_PID=$(pgrep -f "openjdk.*singleton.Main" | head -1)
kill -9 $JVM_PID
```

**Env vars do not reach the JVM through `bloop run`** — bloop runs a persistent background
daemon, and env vars set in the invoking shell aren't inherited by JVMs it forks. If you
need to change a value normally read from an env var at startup (e.g. an internal tuning
constant with no CLI flag), you generally have to edit the source/default and recompile —
treat repeated need for this as a signal the value should get a proper CLI flag or config
option upstream, not just a workaround to memorize.

## Multiple instances / A-B comparisons

This is just "run twice with different isolation knobs" — nothing special beyond Step 2's
isolation table. Give each instance its own port, mongo-db, s3-path-prefix, staged-data-dir,
and log file. Shared infra (docker compose) is fine. If comparing behavior across two
branches/worktrees, make sure you're compiling/running each from its own worktree.

## Container name for `docker exec` (Mongo, etc.)

Container names are prefixed with the worktree directory name and vary
(`<worktree-dir-name>_mongo_1`). Don't hardcode a guessed name — discover it:

```bash
docker ps --format '{{.Names}}' | grep _mongo_
```

or use `scripts/find-mongo-container.sh`.
