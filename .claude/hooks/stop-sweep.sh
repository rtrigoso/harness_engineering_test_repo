#!/usr/bin/env bash
# Inner loop, Stop: end-of-session advisory sweep (lint + typecheck +
# secrets scan + test coverage on uncommitted component changes).
# Degrades gracefully if betterleaks isn't installed locally. Never
# blocks (always exits 0).
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root" || exit 0

npm run lint
npm run typecheck

if command -v betterleaks >/dev/null 2>&1; then
  betterleaks dir --no-banner .
else
  echo "betterleaks not installed, skipping secrets scan"
fi

./scripts/check-test-coverage.sh || true

exit 0
