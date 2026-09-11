# Source Kinds (RSKs): Checking and Loading

A **source kind** ("RSK" / Rootstock Kind) is the definition of a connector (Intercom,
Salesforce, etc.) — its config schema, icon, description. The singleton needs the RSK for
a connector loaded into Mongo before you can create a source that uses it.

## 1. Check what's already loaded

```bash
curl -s http://localhost:$PORT/source-kinds | jq '[.[] | {id, name}]'
```

or `scripts/list-source-kinds.sh $PORT`. A freshly created `--mongo-db` typically has
**none** loaded — this is expected, not a bug.

- If the RSK you need is present, move on.
- If it's absent: if the user specified a connector, load it. If they didn't and the store
  is empty, **ask which connector to use** rather than guessing — this determines what
  credentials you'll need next (see main SKILL.md Step 2).

## 2. Where RSK definitions live

Unless the user says otherwise, use the local checkout at:

```
~/work/precog/web-source-kinds/modules/core/src/main/resources/rootstock-kinds/
```

Filenames are `<connector-name>-<major>.<minor>.<patch>.yml`, e.g. `intercom-5.0.0.yml`.
List available ones with:

```bash
ls ~/work/precog/web-source-kinds/modules/core/src/main/resources/rootstock-kinds/
```

(If that checkout doesn't exist on this machine, fall back to fetching via `gh api
repos/precog/web-source-kinds/contents/...` — but prefer the local path when present, it's
faster and avoids GitHub rate limits.)

To find RSKs supporting interactive OAuth (has `interactiveOAuth2Authorization` in the
YAML):

```bash
grep -l interactiveOAuth2Authorization ~/work/precog/web-source-kinds/modules/core/src/main/resources/rootstock-kinds/*.yml
```

## 3. MongoDB document shape

Collection: `rootstock-yaml`, database is whatever `--mongo-db` the instance used
(default `precog-dev`).

```json
{
  "id": "ConnectorName@X.Y.Z",        // NOTE: no "source:" prefix here (unlike the HTTP API's kindId)
  "config": "<full raw YAML string>",
  "icon": {"format": "svg", "data": "<base64>"},
  "description": "...",
  "instructions": null,
  "configSchema": {
    "Field Name": {"fieldDescription": "...", "sensitive": true}
  },
  "naming": {"type": "singleField", "fieldName": "Field Name"},
  "deprecated": false,
  "gitCommitHash": null
}
```

**Gotcha:** `configSchema` and `naming` are required top-level fields with **no defaults**
in the decoder. A minimal insert with just `id`/`config` decodes to `None` at lookup time,
which surfaces as a confusing 422 "plugin not available" on `/connectivity/source` even
though the document exists in Mongo. Always populate all fields from the source YAML.

## 4. Inserting an RSK

Use `scripts/insert-source-kind.sh <mongo-container> <rsk-id> [yaml-path] [mongo-db]` —
it finds/parses the YAML with `yq` (via `find-rsk-yaml.sh` if you don't pass a path) and
builds/upserts the full document, avoiding the missing-field trap above. `<mongo-container>`
can come from `scripts/find-mongo-container.sh`; `[mongo-db]` defaults to `precog-dev` and
must match the running instance's `--mongo-db`. Example:

```bash
MONGO=$(scripts/find-mongo-container.sh | head -1)
scripts/insert-source-kind.sh "$MONGO" "Intercom@5.0.0"
```

If you need to do it by hand (e.g. the script doesn't cover your case), the shape is:
extract `description`, `naming`, `configSchema`, `icon`, `instructions` from the YAML with
`yq -o=json`, build the full JSON document with `jq`, then `replaceOne({id}, doc,
{upsert:true})` via `mongosh` against `mongodb://localhost:27017/<db>` in the Mongo
container. Match `id` exactly to the `id:` field in the YAML — this is what the HTTP API's
`kindId` (`source:<id>`) resolves against.

## Notes for future improvement

Manually inserting RSKs one at a time via `mongosh`/`jq`/`yq` is a workaround for the
singleton having no bulk-load mechanism for local dev. If this comes up often, a real fix
(e.g. a singleton startup flag to load all RSKs from a directory, or a `POST
/admin/source-kinds/reload` endpoint) would remove this whole category of manual work —
worth raising with the team rather than treating the manual procedure as permanent.
