# Changelog

All notable changes to GSD Antigravity are documented here.

## [0.1.0-beta] — 2026-03-19

### 🚀 Initial Antigravity Fork

First public release of the GSD fork optimized for the Antigravity runtime.

### Added
- **Inline execution fallbacks** for all 13 `Task()`-dependent workflows
- **Skill() fallbacks** for 3 workflows (`autonomous`, `discuss-phase`, `plan-phase`)
- **16 agent compatibility blocks** with Claude→Antigravity tool mapping
- **`antigravity-tools.md`** — complete tool translation reference
- **Parallel tool call optimization** for research and context loading
- **3 project templates**: Go microservice, network tool, infrastructure
- **E2E smoke test** (`tests/smoke-test.sh`) — 21 assertions
- **38 unit tests** for installer Antigravity plumbing
- **GitHub Actions CI** — unit tests (Node 18/20/22), smoke test, package validation
- **`.npmignore`** — lean 518KB package

### Changed
- `package.json` → `@jairnx/gsd-antigravity@0.1.0-beta`
- `config.json` template → `runtime: "antigravity"`, parallelization disabled
- `help.md` → `/gsd-` command syntax, Antigravity-neutral language
- `execute-plan.md` → Pattern A/B/C inline fallback, GEMINI.md support
- `update.md` → points to `@jairnx/gsd-antigravity`
- `join-discord.md` → fork repo + original GSD community links
- Installer → clean output, no `.claude` path warnings, fork branding

### Attribution
Based on [GSD](https://github.com/gsd-build/get-shit-done) by TÂCHES (MIT License).
