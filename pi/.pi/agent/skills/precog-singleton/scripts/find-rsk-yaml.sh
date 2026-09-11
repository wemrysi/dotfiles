#!/usr/bin/env bash
# Find and print the path to the RSK YAML file matching a given RSK id (e.g. "Intercom@5.0.0")
# in a rootstock-kinds directory. Filenames don't reliably derive from the id, so this
# searches file contents for the `id:` field instead of guessing.
#
# Usage: find-rsk-yaml.sh <rsk-id> [rootstock-kinds-dir]
set -euo pipefail

RSK_ID="${1:?usage: find-rsk-yaml.sh <rsk-id> [rootstock-kinds-dir]}"
DIR="${2:-$HOME/work/precog/web-source-kinds/modules/core/src/main/resources/rootstock-kinds}"

if [[ ! -d "$DIR" ]]; then
  echo "rootstock-kinds directory not found: $DIR" >&2
  exit 1
fi

MATCH=$(grep -rlF "id: ${RSK_ID}" "$DIR" | head -1 || true)

if [[ -z "$MATCH" ]]; then
  echo "No RSK file found with id: ${RSK_ID} under $DIR" >&2
  exit 1
fi

echo "$MATCH"
