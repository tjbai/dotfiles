# Ratchets

The strict gate from `~/dev/aui` (ADR 0008, 0027), made portable. One command, `pnpm check`, runs every codifiable rule at error. Budgets are ratchets: they only go down.

Copy the three files in `../scripts/` into the target repo's `checks/` (and repo root for `eslint.config.js`), then wire the config below. Rename the plugin (`meta.name` in `oxlint-plugin.mjs` and the `aui/` prefixes) to the repo's name.

## The gate

```json
"scripts": {
  "fmt": "oxfmt",
  "fmt:check": "oxfmt --check",
  "lint": "NODE_OPTIONS=--experimental-strip-types oxlint --deny-warnings",
  "lint:hooks": "eslint src",
  "typecheck": "tsc -p . --noEmit",
  "deadcode": "knip",
  "test": "vitest run",
  "build": "vite build && tsx checks/bundle.ts",
  "check": "pnpm fmt:check && pnpm lint && pnpm lint:hooks && pnpm typecheck && pnpm deadcode && pnpm test && pnpm build"
}
```

devDependencies: `oxfmt`, `oxlint`, `oxlint-tsgolint`, `@oxlint/plugins`, `eslint`, `eslint-plugin-react-hooks` (v7+), `@typescript-eslint/parser`, `babel-plugin-react-compiler`, `knip`, `vitest`, `tsx`, `typescript`. Pin them.

Order matters: format, then lint, then types, then dead code, then tests, then the build with its bundle budget. Everything before the build is seconds; nothing in the gate is skippable.

## React Compiler: a bailout is a build failure

```ts
// vite.config.ts
react({
  babel: {
    plugins: [["babel-plugin-react-compiler", { panicThreshold: "all_errors" }]],
  },
})
```

`all_errors` in the check build; the shipped build may use `"none"` per the React reference, but if the check build is the shipped build, keep `all_errors`. Next.js: `reactCompiler: true` in `next.config.ts`; check the current Next docs before passing compiler options through it.

## react-hooks v7: the compiler's diagnostics as lint errors

`../scripts/eslint.config.js`, verbatim. oxlint lacks these rules, so this is the one eslint invocation that survives. All twelve rules at error: `rules-of-hooks`, `exhaustive-deps`, `purity`, `immutability`, `set-state-in-render`, `set-state-in-effect`, `refs`, `globals`, `static-components`, `use-memo`, `error-boundaries`, `preserve-manual-memoization`.

## oxlint: everything else, type-aware, all categories error

Skeleton for `.oxlintrc.json`. Comments mark what to adapt.

```jsonc
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "jsPlugins": [{ "name": "aui", "specifier": "./checks/oxlint-plugin.mjs" }],
  "plugins": ["typescript", "unicorn", "oxc", "import", "promise", "node", "jsx-a11y"],
  "options": { "typeAware": true },
  "categories": { "correctness": "error", "suspicious": "error", "perf": "error", "pedantic": "error" },
  "env": { "browser": true, "es2022": true },
  "ignorePatterns": ["dist", "docs", "public"],
  "rules": {
    // size and complexity budgets. set to current reality, then only lower.
    "max-lines": ["error", { "max": 400 }],
    "max-lines-per-function": ["error", { "max": 120 }],
    "max-depth": ["error", 4],
    "max-params": ["error", 5],
    "max-nested-callbacks": ["error", 3],

    // type-aware strictness
    "typescript/no-floating-promises": "error",
    "typescript/await-thenable": "error",
    "typescript/no-misused-promises": "error",
    "typescript/no-unnecessary-type-assertion": "error",
    "typescript/no-unsafe-argument": "error",
    "typescript/no-unsafe-assignment": "error",
    "typescript/no-unsafe-call": "error",
    "typescript/no-unsafe-member-access": "error",
    "typescript/no-unsafe-return": "error",
    "typescript/require-array-sort-compare": "error",
    "typescript/switch-exhaustiveness-check": "error",
    "typescript/no-explicit-any": "error",
    // off, deliberately: each fights a house idiom and catches no bugs.
    "typescript/prefer-readonly-parameter-types": "off",
    "typescript/no-unsafe-type-assertion": "off",
    "typescript/strict-boolean-expressions": "off",
    "typescript/no-confusing-void-expression": "off",
    "typescript/strict-void-return": "off",

    "no-var": "error",
    "no-eval": "error",
    "unicorn/no-abusive-eslint-disable": "error",
    "import/no-unassigned-import": ["error", { "allow": ["**/*.css"] }],
    "no-restricted-imports": ["error", { "patterns": [
      { "group": ["*lucide*", "@heroicons/*", "react-icons*", "@tabler/icons*", "@fortawesome/*", "@mui/*", "antd*"],
        "message": "No icon or component libraries." }
    ]}]
  },
  "overrides": [
    { "files": ["src/**"], "rules": {
      "typescript/no-unnecessary-condition": "error",
      "aui/catch-justification": "error",
      "aui/no-slop-comments": "error"
    }},
    { "files": ["src/**/*.tsx"], "rules": {
      "aui/effect-justification": "error",
      "aui/single-inner-html-sink": "error",
      "no-console": "error"
    }}
  ]
}
```

The `no-restricted-imports` block is a product decision (aui: text-first, no icon libraries). Keep it where that decision holds; drop it where it does not.

## The custom rules (`../scripts/oxlint-plugin.mjs`)

| Rule | Enforces | Adapt |
| --- | --- | --- |
| `effect-justification` | Every `useEffect`/`useLayoutEffect`/`useInsertionEffect` has `// effect: <why>` in the comment block above it | none |
| `catch-justification` | A `catch` rethrows or opens with `// catch: <why>` | none |
| `no-slop-comments` | No narration, filler words, section banners, or commented-out code in `//` comments | extend the `SLOP` list as new patterns appear |
| `single-inner-html-sink` | `innerHTML` and `dangerouslySetInnerHTML` only in one file | change the `Markdown.tsx` filename check |
| `no-color-literals` | No hex/rgb/hsl/oklch literals in TSX; colors come from CSS variables | only for repos with a token or seed system |

Effects are enumerated, not discovered. Beyond the comment, aui tracks a callsite count: grep `useEffect(` in `src/`, record the number in the repo's docs, and treat an increase as a review question.

## Bundle budget (`../scripts/bundle.ts`)

Runs after `vite build`. Five hard limits on `dist/assets`: initial `index-*` chunk, largest chunk, total JS, total CSS, total JS gzip. Set each constant to current reality plus a few percent on day one. When a limit trips: code-split, drop the dependency, import a subpath. Never raise the number. Leave a dated comment above the constants recording what the bundle is made of, so the next person knows what a regression displaced.

For Next.js, replace the `dist/assets` walk with `.next/static/chunks` and keep the same five checks.

## Render budget test

A vitest test that mounts the hot list (500 items) and asserts component-body counts per update: aui's is ≤ 3 bodies per streamed chunk. Count bodies with a module-level counter incremented at the top of the row component under `import.meta.vitest`, or with React Profiler `onRender`. This is the test that catches the coarse-subscription regression the lints cannot see.

## Dead code (knip)

```json
"knip": { "entry": ["checks/*.ts", "checks/*.mjs"], "project": ["src/**", "checks/**"] }
```

No unused files, dependencies, or exports. Runs in the gate.

## react-doctor, pinned and delta-gated

Add `react-doctor` as a devDependency, `--no-telemetry`, and gate on the changed-files delta (see [review.md](review.md)). It is one input; the compiler diagnostics and the hooks lint above are the authority.

## Ratchet discipline

- A trip is a bug in the change, not in the budget. Shrink the code.
- Exceptions live in config with a comment saying why, per file. Inline `eslint-disable` is itself an error (`unicorn/no-abusive-eslint-disable`).
- Rule numbers move in one direction. When a budget is comfortably under, lower it in the same PR that made it so.
- Never give a `.ts` module the same basename as a `.tsx` module in another case (`markdown.ts` vs `Markdown.tsx`). tsgolint's module graph breaks on case-insensitive filesystems with phantom type errors.
- oxfmt is pre-1.0. Accept formatting churn on upgrades; do not hand-align.
