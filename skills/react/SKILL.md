---
name: react
description: "The React hub: the house constitution (compiler-first, state outside React, effects enumerated, composition over boolean props), Vercel's performance and composition rule packs, View Transitions, the strict ratchet gate (React Compiler all_errors, react-hooks v7, type-aware oxlint, bundle budgets), and the audit workflow (react-doctor, Web Interface Guidelines). Use whenever writing, reviewing, refactoring, or setting up a React or Next.js codebase. Triggers on: React, Next.js, component, hook, useEffect, re-render, bundle size, view transition, react doctor, accessibility audit, frontend."
---

# React

Index skill. Read the matching reference before producing React. The constitution applies everywhere; the references go deep.

| Doing | Read |
| --- | --- |
| Setting up or hardening a repo's checks | [reference/ratchets.md](reference/ratchets.md) |
| Writing or refactoring components, state, hooks | [reference/composition.md](reference/composition.md), then [reference/performance.md](reference/performance.md) |
| Performance: waterfalls, bundle, re-renders, hydration | [reference/performance.md](reference/performance.md), then the rule files it points to |
| Animating between UI states | [reference/view-transitions.md](reference/view-transitions.md) |
| Auditing a PR, branch, or whole repo | [reference/review.md](reference/review.md) |

Every rule file under `reference/rules/` has an incorrect example, a correct example, and the why. Read the rule, not just its one-line summary, before you apply it.

## Constitution

Distilled from `~/dev/aui` (ADR 0012, 0014, 0027, 0030; `docs/code-style.md`). Each line is lint-enforced there. When you carry a rule into a new repo, carry its lint too ([reference/ratchets.md](reference/ratchets.md)).

- React renders. It does not own state. Default: state lives in plain modules and components subscribe to narrow slices with `useSyncExternalStore`, one row to its own snapshot. Never mirror external state into `useState`. In a codebase with an established state layer, match that layer instead.
- Derive, don't store. Compute during render. A `useEffect` is a last resort and carries `// effect: <why>` on the line above. Most effects should have been derivations or event handlers.
- The compiler owns memoization. React Compiler from the first commit, `panicThreshold: "all_errors"` in the check build. No manual `useMemo`, `useCallback`, or `React.memo`. The rare exception carries `// memo: <identity it protects>`.
- Compose, don't configure. No boolean prop proliferation. Explicit variant components, compound components sharing context, `children` over `renderX` props. More than five props is a config object: split or inline.
- React 19 idioms. `ref` is a prop (no `forwardRef`), `use()` over `useContext()`, `<Activity>` for show/hide, `startTransition` for non-urgent updates. No loading states for things that can be synchronous.
- Trust owned types. No `?.`, `??`, or re-validation on data this repo defines. Runtime checks only at true boundaries: network, filesystem, env, foreign wire formats. A `catch` rethrows or opens with `// catch: <boundary it absorbs>`.
- Comments are load-bearing or absent. No narration, filler, banners, or commented-out code.
- One DOM sink. `innerHTML` and `dangerouslySetInnerHTML` live in exactly one sanctioned file.
- Ratchets only go down. Size, bundle, and effect-count budgets shrink. Never raise one to pass a check. Exceptions live in config with a comment, never as inline disables.

## Before writing

1. Find the closest sibling component and match its structure, naming, and file placement.
2. Find the repo's gate (`pnpm check` or equivalent) and run it first. If there is none, offer the one in [reference/ratchets.md](reference/ratchets.md).
3. Run the gate again before reporting done. A compiler bailout or a budget trip is a failure, not a warning.

## Amending this skill

When the user corrects the same React theme twice in one session, or once against a rule written here, propose a diff to the right reference file at the next pause. Quote the correction. One rule per pattern. Apply after approval. Skip one-off, context-specific instructions.
