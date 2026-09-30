// The compiler-rule battery oxlint lacks (ADR 0027): eslint-plugin-react-hooks
// v7 diagnostics, all at error. oxlint stays the linter for everything else.
import tsParser from "@typescript-eslint/parser";
import reactHooks from "eslint-plugin-react-hooks";

export default [
  {
    files: ["src/**/*.{ts,tsx}"],
    languageOptions: {
      parser: tsParser,
      parserOptions: { ecmaFeatures: { jsx: true } },
    },
    plugins: { "react-hooks": reactHooks },
    rules: {
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "error",
      "react-hooks/purity": "error",
      "react-hooks/immutability": "error",
      "react-hooks/set-state-in-render": "error",
      "react-hooks/set-state-in-effect": "error",
      "react-hooks/refs": "error",
      "react-hooks/globals": "error",
      "react-hooks/static-components": "error",
      "react-hooks/use-memo": "error",
      "react-hooks/error-boundaries": "error",
      "react-hooks/preserve-manual-memoization": "error",
    },
  },
];
