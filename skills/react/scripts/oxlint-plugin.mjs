// Repo-specific lint rules, run inside oxlint as a JS plugin.

/** Effects are enumerated, not discovered (ADR 0027): each useEffect is a last
 * resort and must say why it exists. Prefer deriving during render. */
const EFFECT_HOOKS = new Set(["useEffect", "useLayoutEffect", "useInsertionEffect"]);
const effectJustification = {
  meta: {
    docs: {
      description: "useEffect must have a `// effect: <why>` comment on the line above",
    },
  },
  create(context) {
    return {
      CallExpression(node) {
        if (node.callee.type !== "Identifier" || !EFFECT_HOOKS.has(node.callee.name)) return;
        const before = context.sourceCode.text.slice(0, node.range[0]);
        const lines = before.split("\n");
        // Walk up the contiguous `//` comment block above the call (a
        // justification may wrap onto several lines); it must contain
        // `effect: <why>` somewhere.
        let justified = false;
        for (let i = lines.length - 2; i >= 0; i--) {
          const line = lines[i].trim();
          if (!line.startsWith("//")) break;
          if (/\/\/\s*effect:\s*\S/u.test(line)) {
            justified = true;
            break;
          }
        }
        if (!justified) {
          context.report({
            node,
            message:
              "useEffect needs a `// effect: <why>` comment on the line above. Prefer deriving during render over effects.",
          });
        }
      },
    };
  },
};

/** All colors derive from the seed variables in src/App.css. No literals. */
const COLOR =
  /(#[0-9a-fA-F]{3}\b|#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{8}\b|\brgba?\(|\bhsla?\(|\boklch\(|\boklab\(|\bcolor-mix\()/u;

const noColorLiterals = {
  meta: {
    docs: { description: "no color literals outside the App.css seed block" },
  },
  create(context) {
    const report = (node) =>
      context.report({
        node,
        message: "Color literal. All colors derive from the seeds in src/App.css.",
      });
    return {
      Literal(node) {
        if (typeof node.value === "string" && COLOR.test(node.value)) report(node);
      },
      TemplateElement(node) {
        if (COLOR.test(node.value.raw)) report(node);
      },
    };
  },
};

/** Markdown.tsx is the single sanctioned HTML sink (docs/performance.md).
 * Everywhere else, build DOM through JSX so React owns the updates. */
const singleInnerHtmlSink = {
  meta: {
    docs: {
      description: "innerHTML / dangerouslySetInnerHTML are allowed only inside src/Markdown.tsx",
    },
  },
  create(context) {
    if (context.filename.endsWith("Markdown.tsx")) return {};
    const report = (node) =>
      context.report({
        node,
        message:
          "innerHTML / dangerouslySetInnerHTML outside src/Markdown.tsx — it is the single sanctioned HTML sink.",
      });
    return {
      AssignmentExpression(node) {
        const l = node.left;
        if (
          l.type === "MemberExpression" &&
          !l.computed &&
          l.property.type === "Identifier" &&
          l.property.name === "innerHTML"
        )
          report(node);
      },
      JSXAttribute(node) {
        if (
          node.name.type === "JSXIdentifier" &&
          (node.name.name === "innerHTML" || node.name.name === "dangerouslySetInnerHTML")
        )
          report(node);
      },
    };
  },
};

/** Swallowing errors is a product decision, not a reflex. A catch block must
 * either rethrow or open with `// catch: <what external failure this maps to>`. */
const catchJustification = {
  meta: {
    docs: { description: "catch blocks must rethrow or carry a `// catch: <why>` comment" },
  },
  create(context) {
    return {
      CatchClause(node) {
        const rethrows = node.body.body.some((s) => s.type === "ThrowStatement");
        if (rethrows) return;
        const openBrace = node.body.range[0];
        const firstStmt = node.body.body[0]?.range[0] ?? node.body.range[1];
        const head = context.sourceCode.text.slice(openBrace, firstStmt);
        if (!/\/\/\s*catch:\s*\S/u.test(head)) {
          context.report({
            node,
            message:
              "catch needs `// catch: <what external failure this maps to>` as its first line, or rethrow. Owned code shapes don't need guarding.",
          });
        }
      },
    };
  },
};

/** Agent-slop comment patterns: narration, filler words, section banners,
 * commented-out code. Comments are rationed — load-bearing or absent. */
const SLOP = [
  [
    /^\/\/\s*(now |first,? |next,? |then |we |here we |this (function|file|method|component) )/iu,
    "narrates instead of informing",
  ],
  [
    /\b(simply|basically|obviously|essentially|gracefully|elegantly?|robust(ly)?|note that|keep in mind|it'?s important|make sure)\b/iu,
    "filler word",
  ],
  [/^\/\/\s*[-=*_]{4,}/u, "section banner"],
  [
    /^\/\/\s*(import |const |let |await |return [^a-z])/u,
    "commented-out code — delete it, git remembers",
  ],
];

const noSlopComments = {
  meta: {
    docs: { description: "no narration, filler, banners, or commented-out code in comments" },
  },
  create(context) {
    return {
      Program(node) {
        const lines = context.sourceCode.text.split("\n");
        lines.forEach((raw, i) => {
          const m = /(?<!:)\/\/.*$/u.exec(raw);
          if (!m) return;
          const comment = m[0].trim();
          for (const [re, why] of SLOP) {
            if (re.test(comment)) {
              context.report({
                node,
                message: `slop comment at line ${i + 1} (${why}): \`${comment.slice(0, 60)}\`. Comments are load-bearing or absent.`,
              });
              return;
            }
          }
        });
      },
    };
  },
};

export default {
  meta: { name: "aui" },
  rules: {
    "effect-justification": effectJustification,
    "no-color-literals": noColorLiterals,
    "single-inner-html-sink": singleInnerHtmlSink,
    "catch-justification": catchJustification,
    "no-slop-comments": noSlopComments,
  },
};
