#!/usr/bin/env bash
# Find running singleton-related Mongo container name(s). Container names are prefixed
# with the worktree directory name and vary, so don't hardcode a guess.
# Usage: find-mongo-container.sh
set -euo pipefail

MATCHES=$(docker ps --format '{{.Names}}' | grep '_mongo_' || true)

if [[ -z "$MATCHES" ]]; then
  echo "No running container matching '_mongo_' found. Is docker compose up in the relevant worktree?" >&2
  exit 1
fi

echo "$MATCHES"
