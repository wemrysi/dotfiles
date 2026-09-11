#!/usr/bin/env bash
# Wait until a singleton instance's /ping endpoint is healthy.
# Usage: wait-for-ready.sh <port> [timeout_seconds]
set -euo pipefail

PORT="${1:?usage: wait-for-ready.sh <port> [timeout_seconds]}"
TIMEOUT="${2:-300}"
DEADLINE=$((SECONDS + TIMEOUT))

echo "Waiting for http://localhost:$PORT/ping (timeout ${TIMEOUT}s)..."
while (( SECONDS < DEADLINE )); do
  if curl -sf "http://localhost:$PORT/ping" > /dev/null 2>&1; then
    echo "Ready after ${SECONDS}s"
    exit 0
  fi
  sleep 1
done

echo "Timed out after ${TIMEOUT}s waiting for http://localhost:$PORT/ping" >&2
exit 1
