# Coding

Language-agnostic first-pass rules. Code the user calls "slop" violates one of these. Python specifics: [python.md](python.md).

## Comments

- Zero inline comments by default. This covers code you write and comments you inherit inside code you touch.
- Exception: a rare, thin, load-bearing note for a genuine hazard or a "why is this weird" justification — a runtime constraint, security invariant, replay/policy hazard, or model-facing contract. In Python the house form is `# NOTE(tj) -- ...`.
- Never re-add a comment the user or a cleanup pass deleted.
- No section banners, no narration comments, no commented-out code, no docstrings that restate the flow.

## Defensive code

- Trust contracts this repo owns. If a schema, typed caller, database constraint, or migration owns a shape, do not re-validate it. Crash loudly on violation.
- Guard only true boundaries: user input before validation, third-party responses, env vars, secrets, filesystem, network, database availability.
- No fallback parsing for formats the writer never emits. No speculative branches for providers, versions, or futures that do not exist yet.

## Diffs

- Smallest accurate change. Touch nothing the task does not require.
- Never reformat untouched lines. If a formatter reflows them, revert those hunks.
- No no-op refactors: variable extractions, blank-line shuffles, import reorderings that change nothing.

## Structure

- No one-use helpers. No template/builder indirection for something used once or twice. A little duplication beats the wrong abstraction.
- But do consolidate: when many parallel arguments travel together through calls, replace them with one small typed object (dataclass or equivalent) instead of loose params.
- Flat, obvious control flow. Prefer one exhaustive switch/match that makes every case visible over nested conditionals or dispatch tables.
- Derive, do not store. Persist only what cannot be computed later from data you already have.

## Naming

- Simple, self-documenting, common words. No jargon codenames ("spine", "posture").
- One canonical name per concept, used everywhere it appears — across layers, logs, columns, and docs.
- Enums (Python: `StrEnum`) over loose magic strings for closed sets.
- Match sibling naming conventions exactly (tool namespaces, prefixes, casing).

## Formatting

- Compact over ceremonial. One-line imports and signatures where line length allows.
- Blank lines mark real phases inside long functions, not decoration between every statement.
