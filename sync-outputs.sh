#!/usr/bin/env bash

set -euo pipefail

LOCAL="./outputs"
REMOTE="gdrive:Share"

STATE_DIR="${HOME}/.local/state/rclone-bisync"
MARKER="${STATE_DIR}/outputs.initialized"

mkdir -p "$STATE_DIR"

COMMON=(
  --exclude '~$*.xlsx'
  --conflict-resolve newer
  --conflict-loser pathname
  -P
)

if [[ ! -f "$MARKER" ]]; then
  # Copy feddback tracker to outputs directory
  cp *.xlsx "$LOCAL"

  # --resync를 붙이면 진짜 양방향 sync가 아니라 매번 재초기화. 
  echo "First run: rclone bisync with --resync"

  rclone bisync "$LOCAL" "$REMOTE" --resync "${COMMON[@]}"

  touch "$MARKER"
  echo "Initial bisync completed."
else
  echo "Normal run: rclone bisync"

  rclone bisync "$LOCAL" "$REMOTE" "${COMMON[@]}"
fi
