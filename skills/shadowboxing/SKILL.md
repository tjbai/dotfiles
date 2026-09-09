---
name: shadowboxing
description: Ships a query or code-path rewrite behind paired shadow + cutover feature gates with a reviewer-legible diff. Use when asked to shadow, canary, dual-gate, or cut over a query optimization or read-path rewrite, or to "do it the shadowboxing way".
---

# Shadowboxing

Ship a rewrite next to the legacy path. Legacy keeps serving. The new path spars in the background until it proves it returns the same answer, then takes over behind a gate.

If the repo already has a shadow rollout, copy its names, outcomes, and log shape exactly. Do not invent a second convention.

## Two gates, three sources

Two per-user feature gates:

- `<feature>_shadow` — on merge: internal users 100% + a small slice of everyone.
- `<feature>` — the cutover gate. 0% on merge.

`resolveXSource({ userId, ... })` reads both gates once per request and returns one of:

| source | runs | caller gets |
|---|---|---|
| `legacy` | legacy query | legacy rows |
| `shadow` | legacy on the request path, new query fire-and-forget after | legacy rows |
| `cutover` | new query only | new rows reshaped to the legacy row shape |

Cutover is checked first and wins. A degraded gate evaluation falls back to `legacy` with a warn and skips the shadow check. Rollback is turning cutover off.

## Shadow runner rules

- Never on the request path: dispatch with `void` after the served `await` resolves, not concurrently before it. Two queries in the request window compete with each other.
- Bounded: pass an abort signal with a fixed timeout (10 s is a good default) to the real query builder.
- Never rejects: returns `Promise<void>` and classifies every failure. If the served query failed, do nothing.
- Outcomes are exactly `match | mismatch | shadow_timeout | shadow_error`. One log line per run with `served_count`, `shadow_count`, `duration_ms`, and on mismatch the `served_only_count` / `shadow_only_count` / per-field mismatch counts. One count metric tagged `outcome`; one latency distribution tagged `source` + `query`.
- Compare order-insensitively by id, plus row count (catches duplicates), plus every field the caller reads.

## Writing the diff so it reads

One new module, one additive router diff. Say so in the PR body: "You can review the router diff without reading that file, and that file without reading the router."

The module owns everything new: `resolveXSource`, `buildXFrom<Source>` (a lazy thenable that runs nothing until awaited and accepts an abort signal), row reshape, `compareX`, `runXShadow`, metrics, logs.

The router keeps the legacy builder byte-identical and adds three visible steps:

```ts
// 1. build the new query from the same filters. Lazy: nothing runs until awaited.
const pivot = buildXFromSource<RowOf<typeof query>>({ ...same filters })

// 2. serve from one. legacy and shadow both take `await query`.
const { data, error } = source === 'cutover' ? await pivot : await query
if (error) { /* unchanged */ }

// 3. shadow only, after the served result. `void`: nothing awaits it.
if (source === 'shadow') {
  void runXShadow({ procedure, userId, servedRows: data, runShadowQuery: () => pivot })
}
```

Rules that keep it legible:

- The only deleted router lines are the `await` lines. Everything downstream still reads the same `{ data, error }`.
- Infer the new row type from the legacy builder (`RowOf<typeof query>`) so the two sides cannot drift and the call site needs no casts.
- Duplicate the filters in the new query instead of sharing a builder with legacy. Flag it as deliberate: shadow verifies the duplication in production, and a unit test pins the exact filter chain.
- Legacy query, both gates, and the module all stay in this PR. Deleting them is a follow-up PR named in the PR body.

## Tests

- Unit: the new query sends the exact filter chain for every legacy filter, applies none when legacy applied none, and the abort signal reaches the builder.
- Router: drive all three sources with a mock that returns different rows from each source. Assert `shadow` serves legacy rows and records a mismatch afterwards.

## PR body

Sections, in order: summary with profiled before/after numbers; "How to read the diff" (the three steps and the independence claim); sources table; what shadow reports (metric names, tags, outcomes); the new query and reshape; numbered rollout (merge → watch shadow for zero `mismatch`/`shadow_error`/`shadow_timeout` → compare new-query latency to the legacy span → ramp cutover by user → rollback is gate off → follow-up deletes legacy and gates); "Not in this PR".
