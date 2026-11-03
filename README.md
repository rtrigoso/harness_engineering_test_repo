# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some Oxlint rules.

## Scripts

- dev: start the Vite dev server
- build: type-check (`tsc -b`) and build for production
- lint: run oxlint
- typecheck: type-check only, no emit (`tsc -b --noEmit`)
- test: run the Vitest test suite
- preview: preview the production build locally

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Oxc](https://oxc.rs)
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/)

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the Oxlint configuration

If you are developing a production application, we recommend enabling type-aware lint rules by installing `oxlint-tsgolint` and editing `.oxlintrc.json`:

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["react", "typescript", "oxc"],
  "options": {
    "typeAware": true
  },
  "rules": {
    "react/rules-of-hooks": "error",
    "react/only-export-components": ["warn", { "allowConstantExport": true }]
  }
}
```

See the [Oxlint rules documentation](https://oxc.rs/docs/guide/usage/linter/rules) for the full list of rules and categories.

## Harness

This repo's constraints, GC rules, and enforcement status are declared in
[`HARNESS.md`](./HARNESS.md). See that file for the full picture; this
section only covers local setup for the one piece of tooling you need to
install yourself.

### Secrets scanning (Betterleaks)

- tool: [betterleaks](https://github.com/betterleaks/betterleaks)
- pinned version: v1.9.0 (v1.x stable branch)
- mode: detection-only (no `-v`/`-a` flags — no live network calls)
- runs: locally via a Claude Code `Stop` hook (advisory), and in CI on every
  PR via `pr-checks.yml` (blocking)

Install locally:

```sh
brew install --cask betterleaks/tap/betterleaks@1
```

Run it by hand:

```sh
betterleaks dir --no-banner .
```

CI downloads its own pinned copy of the binary, so no local install is
required to open a PR — only to get the advisory check during local
sessions.
