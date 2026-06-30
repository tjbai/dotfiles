---
name: running-react-doctor
description: >-
  Runs Million's React Doctor CLI to audit React/Next.js code for bugs,
  performance, accessibility, and maintainability issues. Use when auditing a PR
  or branch for React quality, reviewing changed components, or asked to "run
  react doctor" / capture findings into doctor.md.
---

# Running React Doctor

React Doctor (`react-doctor`, by Million) audits React/Next.js code for bugs,
performance, accessibility, and maintainability issues. Run it via `npx`, or
through the project's package manager if it's installed as a devDependency.

## When to use

- Auditing a PR or branch before merge for React quality regressions.
- Reviewing the changed components in the current work.
- The user asks to "run react doctor", "audit the React code", or to record
  findings in `doctor.md`.

## How to run

If `react-doctor` is a project devDependency, prefer the pinned local version
(`pnpm exec react-doctor` / `npx react-doctor`). Otherwise use the published
CLI: `npx -y react-doctor@latest`.

PR / changed-only scan (the usual mode — only diffs vs the base branch). Use the
repo's integration branch as `--base` (often `origin/main` or `origin/dev`):

```bash
npx -y react-doctor@latest --scope changed --base origin/main --verbose --no-dead-code --no-telemetry
```

Full-repo scan:

```bash
npx -y react-doctor@latest --verbose --no-telemetry
```

Notes on flags:

- `--scope changed --base <ref>` limits the scan to files changed vs `<ref>`.
- `--no-dead-code` skips the dead-code pass (slow, often noisy).
- `--no-telemetry` disables phone-home.
- `--verbose` prints every finding with file:line and a docs link.

If the repo's `.npmrc` uses env interpolation (e.g. `${SOME_TOKEN}`), a harmless
`Failed to replace env in config` warning may print. Ignore it.

## Do not use the installer

Do **not** run `react-doctor install`. It sprays skills/hooks into every agent
tool directory (Amp, Claude Code, Codex, Cursor, etc.). Prefer a tailored setup:
add `react-doctor` as a project devDependency (and a `doctor` script) if you want
it pinned, plus this skill.

## Reading and recording findings

Each finding has a category (Bugs / Performance / Accessibility /
Maintainability), a severity (✖ error or ⚠ warning), a rule, and file:line
locations. Before fixing any rule, follow its docs link (curl with no cache) to
confirm the canonical fix and check for false positives.

Track the audit backlog in a `doctor.md` (e.g. under a scratch dir): record the
command run, the totals, and a per-rule list of locations with a status (todo /
fixed / wontfix). Update it as items are knocked out. Treat React Doctor as one
input — pair it with a manual pass against any React best-practices skills
available (re-render hygiene, composition, client/server boundaries) since the
linter misses architectural issues.
