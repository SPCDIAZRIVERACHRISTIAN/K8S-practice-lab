#!/usr/bin/env bash
# Alias for reset-notes.sh — use before sharing or publishing the repo
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/reset-notes.sh" "$@"
