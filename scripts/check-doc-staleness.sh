#!/usr/bin/env bash
# GC rule: README.md should mention every script defined in package.json.
# Report-only — always exits 0. See HARNESS.md > Garbage Collection.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pkg="$repo_root/package.json"
readme="$repo_root/README.md"

missing=()
while IFS= read -r script_name; do
  if ! grep -q -- "$script_name" "$readme"; then
    missing+=("$script_name")
  fi
done < <(jq -r '.scripts | keys[]' "$pkg")

if [ "${#missing[@]}" -eq 0 ]; then
  echo "doc-staleness: all package.json scripts are mentioned in README.md"
else
  echo "doc-staleness: README.md is missing these package.json scripts:"
  printf '  - %s\n' "${missing[@]}"
fi

exit 0
