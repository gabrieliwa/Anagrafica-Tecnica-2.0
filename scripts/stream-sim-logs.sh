#!/usr/bin/env bash
set -euo pipefail

APP_PROCESS="${1:-AnagraficaTecnica}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${ROOT_DIR}/anagrafica tecnica app/logs"
STAMP="$(date +"%Y%m%d-%H%M%S")"
LOG_FILE="${LOG_DIR}/sim-${APP_PROCESS}-${STAMP}.log"

mkdir -p "${LOG_DIR}"

echo "Streaming Simulator logs for process: ${APP_PROCESS}"
echo "Saving to: ${LOG_FILE}"
echo "Press Ctrl+C to stop."

if ! xcrun --find simctl >/dev/null 2>&1; then
  if [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
  fi
fi

if ! xcrun --find simctl >/dev/null 2>&1; then
  echo "Error: simctl not found."
  echo "Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  echo "Or install Command Line Tools: xcode-select --install"
  exit 1
fi

xcrun simctl spawn booted log stream \
  --style compact \
  --predicate "process == \"${APP_PROCESS}\"" \
  | tee -a "${LOG_FILE}"
