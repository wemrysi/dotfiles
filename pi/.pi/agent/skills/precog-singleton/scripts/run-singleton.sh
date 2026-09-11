#!/usr/bin/env bash
# Start a singleton instance in the background, detached from this shell, and wait for it
# to become healthy. Prints the PID and log file path on success.
#
# Usage: run-singleton.sh <worktree-dir> <port> <log-file> [-- extra bloop-run args/services...]
#
# Example:
#   scripts/run-singleton.sh ~/work/precog/services/main 8080 /tmp/singleton-main.log \
#     -- --mongo-db precog-dev-a server pipeline-load scheduler
set -euo pipefail

WORKTREE="${1:?usage: run-singleton.sh <worktree-dir> <port> <log-file> [-- extra args]}"
PORT="${2:?}"
LOG="${3:?}"
shift 3
if [[ "${1:-}" == "--" ]]; then shift; fi
EXTRA_ARGS=("$@")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$WORKTREE"
echo "Starting singleton in $WORKTREE on port $PORT, logging to $LOG"

nohup bloop run singleton --main precog.service.singleton.Main -- \
  --port "$PORT" "${EXTRA_ARGS[@]}" > "$LOG" 2>&1 &
BGPID=$!
disown "$BGPID"
echo "Launched PID $BGPID"

"$SCRIPT_DIR/wait-for-ready.sh" "$PORT" 300
