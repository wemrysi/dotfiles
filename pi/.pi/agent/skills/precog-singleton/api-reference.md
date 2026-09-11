# HTTP API Reference

Full OpenAPI specs live at `~/work/precog/api-specs/reference/`:

- `public-http-api.yaml` — the main source/destination/pipeline surface
- `admin-http-api.yaml`
- `metadata-http-api.yaml`
- `schemas/` — shared schema definitions

Consult these for authoritative request/response shapes, especially for anything not
covered below, or when a call returns something unexpected. What follows are the
endpoints/shapes that come up repeatedly — a starting point, not a substitute for the spec.

Auth: none needed — `DummyAuth` attributes every request to the instance's `--tenant-id`.

## Health

```
GET /ping   → 200 "pong" when ready
```

## Source kinds

```
GET /source-kinds   → list of {id, name, ...} for all loaded RSKs
```

## Connectivity check (validate credentials before creating a source)

```
POST /connectivity/source
Content-Type: application/json

{
  "kindId": "source:ConnectorName@X.Y.Z",
  "config": [
    {"name": "Field Name 1", "value": "..."},
    {"name": "Field Name 2", "value": "..."}
  ]
}
```

`config` entries' `name`s must match the RSK's `configSchema` field names exactly.

Responses (all `200 OK` except the last):

- `{"connected": {"sourceValidationId": "...", "expiresAt": "..."}}` — credentials work.
  `sourceValidationId` can be passed to `POST /sources` instead of re-sending config; it
  expires per `expiresAt` (singleton default TTL: 1 hour).
- `{"failed": {"type": "input-required"|"auth-required", "message": "..."}}` — known,
  user-actionable failure.
- `{"errored": {"message": "..."}}` — unexpected error.
- `422` — `kindId` doesn't match any loaded RSK (see `source-kinds.md`).

## Sources

```
POST /sources                     — create; body can reuse {"sourceValidationId": "..."}
                                     or full config, per the connectivity check above
POST /sources/{id}/refresh        — re-trigger dataset discovery
GET  /sources/{id}/datasets       — list discovered datasets (204 = not discovered yet)
```

## Destinations

```
POST /destinations   — e.g. Snowflake; required if a pipeline will vectorize
```

## Pipelines

```
POST  /pipelines                        — vectorize: true to enable vectorization
PUT   /pipelines/{id}/vectorize         — toggle vectorize on an existing pipeline
POST  /pipelines/{id}/loads             — trigger a load
                                           202 = accepted (in-band datasets exist)
                                           204 = no in-band datasets yet — NOT an error,
                                                 it means the initial (out-of-band) load
                                                 is still running
PATCH /pipelines/{id}/datasets          — {"action": "add"|"remove"|"renew"|"abort",
                                            "datasetIds": [...]}
GET   /pipelines/{id}/status            — per-dataset outOfBand/inBand state
```

### Dataset load phases

Each dataset in a pipeline goes through:

- **outOfBand** — initial fetch + write from source → S3 staging (the initial load).
- **inBand** — subsequent delta/standard loads, once an initial load has succeeded.

States progress `staging` → `initial-writing` → `succeeded` (or `failed`). Poll
`GET /pipelines/{id}/status` rather than assuming a fixed wait time.

**After a failed load, don't delete the pipeline** — use `PATCH .../datasets` with
`{"action": "renew", "datasetIds": [...]}` to retry against already-staged data.
