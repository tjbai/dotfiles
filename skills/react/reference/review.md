# Review

Auditing React code: a PR, a branch, or a whole repo. Three passes, in order. The linters find the mechanical faults; the manual pass finds the architectural ones.

## 1. The repo's own gate

Run `pnpm check` (or whatever the repo has) on the branch first. If it fails, that is the review. If the repo has no gate, note it and offer [ratchets.md](ratchets.md).

## 2. react-doctor

Million's `react-doctor` audits for bugs, performance, accessibility, and maintainability. Prefer the pinned devDependency; fall back to the published CLI.

Changed-files scan, the usual mode. `--base` is the repo's integration branch (`origin/main`, `origin/dev`):

```bash
npx -y react-doctor@latest --scope changed --base origin/main --verbose --no-dead-code --no-telemetry
```

Full-repo scan:

```bash
npx -y react-doctor@latest --verbose --no-telemetry
```

Flags: `--scope changed --base <ref>` limits to the diff; `--no-dead-code` skips the slow, noisy dead-code pass; `--no-telemetry` stops the phone-home; `--verbose` prints every finding with `file:line` and a docs link. A `Failed to replace env in config` warning from an `.npmrc` with env interpolation is harmless.

Never run `react-doctor install`. It sprays skills and hooks into every agent tool directory on the machine. Pin it as a devDependency with a `doctor` script instead.

Before fixing a finding, open its docs link (fetch uncached) to confirm the canonical fix and rule out a false positive.

## 3. Manual pass

Against the constitution in [../SKILL.md](../SKILL.md) and the rule packs, in this order:

1. Effects: every `useEffect` justified, or a derivation or event handler in disguise? (`rules/rerender-derived-state-no-effect.md`, `rules/rerender-move-effect-to-event.md`)
2. Memoization: any manual `useMemo`/`useCallback`/`React.memo` the compiler would have owned? Any compiler bailout?
3. Composition: boolean prop proliferation, `renderX` props, `forwardRef`, inline component definitions. (`composition.md`)
4. Waterfalls and bundle: sequential awaits, barrel imports, heavy deps on the initial chunk. (`performance.md` sections 1 and 2)
5. Boundaries: defensive `?.`/`??` on owned types, swallowed catches, more than one HTML sink.

## Web Interface Guidelines

For UI surface review (accessibility, focus, motion, forms, typography), fetch Vercel's current rule set and apply it to the specified files:

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

The fetched document defines both the rules and its terse `file:line` output format. Fetch fresh each time; do not cache a copy in the skill.

## Recording

Track the backlog in a `doctor.md` under the repo's scratch area: the command run, totals, and a per-rule list of locations with a status (todo, fixed, wontfix). Update it as items close. A `wontfix` needs a one-line reason.
