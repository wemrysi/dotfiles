#!/usr/bin/env bash
# Insert (upsert) an RSK / source kind into a singleton's MongoDB rootstock-yaml
# collection, building the full document (id, config, icon, description, instructions,
# configSchema, naming) so it doesn't fall into the "missing configSchema/naming decodes
# to None -> 422 plugin not available" trap.
#
# Requires: docker, jq, yq (mikefarah/yq or yq-go; must support `-o=json`)
#
# Usage: insert-source-kind.sh <mongo-container> <rsk-id> [yaml-path] [mongo-db]
#   <mongo-container>  e.g. from find-mongo-container.sh
#   <rsk-id>           e.g. "Intercom@5.0.0" (must exactly match the YAML's `id:` field)
#   [yaml-path]         defaults to the result of find-rsk-yaml.sh <rsk-id>
#   [mongo-db]          defaults to "precog-dev" (must match the running instance's --mongo-db)
set -euo pipefail

MONGO_CONTAINER="${1:?usage: insert-source-kind.sh <mongo-container> <rsk-id> [yaml-path] [mongo-db]}"
RSK_ID="${2:?usage: insert-source-kind.sh <mongo-container> <rsk-id> [yaml-path] [mongo-db]}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAML_PATH="${3:-$("$SCRIPT_DIR/find-rsk-yaml.sh" "$RSK_ID")}"
MONGO_DB="${4:-precog-dev}"

if ! command -v yq >/dev/null 2>&1; then
  echo "yq not found on PATH. Try: nix run nixpkgs#yq-go -- ..." >&2
  exit 1
fi

YAML_CONTENT=$(cat "$YAML_PATH")
DESCRIPTION=$(yq -o=json '.description // ""' "$YAML_PATH")
NAMING=$(yq -o=json '.naming' "$YAML_PATH")
CONFIG_SCHEMA=$(yq -o=json '.configSchema' "$YAML_PATH")
ICON=$(yq -o=json '.icon // null' "$YAML_PATH")
INSTRUCTIONS=$(yq -o=json '.instructions // null' "$YAML_PATH")

DOC=$(jq -n \
  --arg id "$RSK_ID" \
  --arg config "$YAML_CONTENT" \
  --argjson description "$DESCRIPTION" \
  --argjson naming "$NAMING" \
  --argjson configSchema "$CONFIG_SCHEMA" \
  --argjson icon "$ICON" \
  --argjson instructions "$INSTRUCTIONS" \
  '{id: $id, config: $config, icon: $icon, description: $description,
    instructions: $instructions, configSchema: $configSchema, naming: $naming,
    deprecated: false, gitCommitHash: null}')

echo "Upserting RSK '$RSK_ID' from $YAML_PATH into ${MONGO_CONTAINER}:${MONGO_DB}.rootstock-yaml"

docker exec -i "$MONGO_CONTAINER" mongosh --quiet "mongodb://localhost:27017/${MONGO_DB}" --eval "
  const doc = $DOC;
  const res = db['rootstock-yaml'].replaceOne({id: doc.id}, doc, {upsert: true});
  print(JSON.stringify(res));
"
