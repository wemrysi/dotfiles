#!/usr/bin/env bash
# List source kinds (RSKs) currently loaded in a running singleton instance.
# Usage: list-source-kinds.sh <port>
set -euo pipefail

PORT="${1:?usage: list-source-kinds.sh <port>}"

curl -sf "http://localhost:$PORT/source-kinds" | jq -c '.[] | {id, name}'
