# HARNESS.md

## Status

<!-- Updated manually. No audit agent exists in this environment, so this
     block does not auto-update — treat it as accurate as of the date below. -->

- Last updated: 2026-11-03
- Enforcement ratio:
  - 6/7 deterministic
  - 1/7 agent
- Regression flag: n/a (no reflection/session-tracking mechanism in this
  environment)

## Context

**Stack:**
- build_tool: vite@8
- framework: react@19
- language: typescript@7
- type_check_config: tsconfig.app.json, tsconfig.node.json (project references)
- linter: oxlint
- test_runner: vitest
- backend: none
- remote: rtrigoso/harness_engineering_test_repo

**Conventions (observed):**
- Components live under `src/`, PascalCase filenames (e.g. `App.tsx`).
- Entry point `src/main.tsx` → `App.tsx`. Vite/TS scaffold files
  (main.tsx, vite-env.d.ts, test-setup.ts, vite.config.ts) are exempt from component-naming checks —
  they are not components.
- Static assets under `src/assets/`.

**Tooling added by this harness setup:**
- [Betterleaks](https://github.com/betterleaks/betterleaks) (v1.x stable) —
  secrets scanner, installed locally by the developer and downloaded fresh
  in CI. Run in detection-only mode (no `-v`/`-a` flags): no live network
  calls, no credential validation, just pattern/entropy-based detection.
- Vitest — test runner. Installed and wired to `npm run test`. uses `happy-dom` as the DOM environment because jsdom requires a newer version on Node than the LTS at the time of writing (v22.14.0)

## Constraints

### Lint clean
- **Rule**: All committed `.ts`/`.tsx` files must pass `oxlint` with zero errors
- **Enforcement**: deterministic
- **Tool**: `npm run lint`
- **Scope**: commit

### No console.log in committed code
- **Rule**: `console.log` calls must not be committed to `src/`
- **Enforcement**: deterministic
- **Tool**: `npm run lint` (`no-console` rule in `.oxlintrc.json`)
- **Scope**: commit

### Type-check clean
- **Rule**: The project must compile with no TypeScript errors
- **Enforcement**: deterministic
- **Tool**: `npm run typecheck` (`tsc -b --noEmit`)
- **Scope**: pr

### No secrets in source
- **Rule**: No committed source file may contain any of the following:
  - API keys
  - tokens
  - passwords
  - private keys
- **Enforcement**: deterministic
- **Tool**: `betterleaks dir --no-banner --exit-code 1 .` (detection-only,
  v1.x). Runs in two places:
  - advisory at commit (inner loop, via the `Stop` hook)
  - blocking at PR time (middle loop, via `pr-checks.yml`)
- **Scope**: pr (blocking copy); also run advisory at commit

### Component naming
- **Rule**: All `.ts`/`.tsx` filenames must be PascalCase, excluding the entry-point allowlist:
  - `main.tsx`
  - `vite-env.d.ts`
  - `test-setup.ts`
  - `vite.config.ts`
- **Enforcement**: deterministic (heuristic — filename-based, not a true
  semantic check; a file can be PascalCase and still not actually contain a
  component, or vice versa. Accepted as an approximation in exchange for
  zero LLM cost and full determinism.)
- **Tool**: `npm run lint` (uses `unicorn/filename-case` from `oxlint`)
- **Scope**: commit

### HARNESS.md accuracy
- **Rule**: `HARNESS.md` claims (tool paths, enforcement/scope values, the status block's enforcement ratio) must match the actual repo state
- **Enforcement**: agent (`anthropics/claude-code-action`). The only constraint using an agent in this harness. Every other constraint is deterministic.
- **Tool**: `.github/workflows/harness-doc-review.yml` job that runs at PR time, on HARNESS.md diffs and the `harness-doc-audit` job that runs on a monthly loop.
- **Scope**: pr to main and on a monthly schedule, which creates a github issue.

### Test coverage on new components
- **Rule**: Every added or modified `.tsx` component under `src/` must have a sibling `Name.test.tsx` (or `spec.tsx`) file
- **Enforcement**: deterministic (heuristic - file existence, not real coverage; same tradeoff as the naming check)
- **Tool**: `scripts/check-test-coverage.sh`. Runs advisory at commit and blocks on pr 
- **Scope**: pr and at commit

## Garbage Collection

### Dependency freshness
- **Rule**: Flag dependencies in `package.json` more than 2 major versions
  behind latest
- **Check**: `npm outdated` (report-only; manual interpretation)
- **Cadence**: weekly

### Dead code / unused exports
- **Rule**: Flag exported symbols with no in-repo importer
- **Check**: `npx ts-prune` (report-only)
- **Cadence**: weekly

### Documentation staleness
- **Rule**: `README.md` should mention every script defined in
  `package.json`
- **Check**: `scripts/check-doc-staleness.sh` (report-only)
- **Cadence**: monthly (runs in the same weekly workflow for simplicity)

## Observability / Regression Detection

- Cadence:
  - audit: n/a (no `/harness-audit` equivalent in this environment)
  - GC: weekly (`outer-loop.yml`)
  - reflect: n/a (no session-reflection mechanism here)
- Cadence non-compliance threshold: n/a — nothing to compare against yet
- Reflection drought threshold: n/a

## Rung vs. reach

The secrets and component-naming constraints are deterministic at the
**rung** level (the check itself is mechanical and reliable) but held back
at the **reach** level: `pr-checks.yml` is not yet marked as a required
branch-protection check, so a failing PR check does not actually block a
merge to `main` yet. This is deliberate — the team is watching these run
cleanly for a while before making them mandatory. See the harness-engineering
docs' "hold back reach, not rigor" principle.

## What's explicitly out of scope

- Branch protection on `main` — deliberately deferred, not a gap.
- Writing actual component tests — tooling is ready; authoring tests is
  separate follow-up work.
