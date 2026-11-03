#!/usr/bin/env bash
# Constraint: every added or modified .tsx component under src/ must have a
# sibling Name.test.tsx (or .spec.tsx). Deterministic heuristic (file
# existence, not semantic coverage) — see HARNESS.md > Constraints > Test
# coverage on new components.
#
# Two modes, selected by the BASE_REF env var:
#   - CI (PR time, middle loop): BASE_REF set to the PR base SHA/ref.
#     Diffs BASE_REF...HEAD for added/modified .tsx files. Blocking.
#   - Local (inner loop, Stop hook): BASE_REF unset. Looks at uncommitted
#     working-tree changes (staged, unstaged, and untracked) instead.
#     Caller treats this as advisory.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root" || exit 0

allowlist=("main.tsx" "vite-env.d.ts")

is_allowed() {
  local name="$1"
  for allowed in "${allowlist[@]}"; do
    [ "$name" = "$allowed" ] && return 0
  done
  return 1
}

changed=()
if [ -n "${BASE_REF:-}" ]; then
  while IFS= read -r file; do
    [ -n "$file" ] && changed+=("$file")
  done < <(git diff --name-only --diff-filter=AM "$BASE_REF"...HEAD -- '*.tsx')
else
  while IFS= read -r file; do
    [ -n "$file" ] && changed+=("$file")
  done < <(git diff --name-only --diff-filter=AM HEAD -- '*.tsx' 2>/dev/null)
  while IFS= read -r file; do
    [ -n "$file" ] && changed+=("$file")
  done < <(git ls-files --others --exclude-standard -- '*.tsx')
fi

violations=()
for file in "${changed[@]+"${changed[@]}"}"; do
  [ -z "$file" ] && continue
  base="$(basename "$file")"
  is_allowed "$base" && continue
  case "$base" in
    *.test.tsx|*.spec.tsx) continue ;;
  esac

  dir="$(dirname "$file")"
  stem="${base%.tsx}"
  if [ ! -f "$dir/$stem.test.tsx" ] && [ ! -f "$dir/$stem.spec.tsx" ]; then
    violations+=("$file")
  fi
done

if [ "${#violations[@]}" -eq 0 ]; then
  echo "test-coverage: all changed components have a sibling test file"
  exit 0
else
  echo "test-coverage: these changed components are missing a sibling test file:"
  printf '  - %s\n' "${violations[@]}"
  exit 1
fi
