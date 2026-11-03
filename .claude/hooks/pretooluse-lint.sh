#!/usr/bin/env bash
# Inner loop, PreToolUse on Write|Edit: advisory lint on the touched file.
# Reads the hook's stdin JSON directly — never blocks (always exits 0).
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root" || exit 0

file="$(jq -r '.tool_input.file_path // empty')"

case "$file" in
  *.ts|*.tsx)
    ./node_modules/.bin/oxlint "$file" 2>&1 || true
    ;;
esac

exit 0
