// Hard bundle budget. Run with `tsx checks/bundle.ts` after `vite build`.
// The limits are a ratchet: they only go DOWN. If you trip one, shrink the
// bundle (code-split, drop the dependency, import a subpath) — do not raise it.
import fs from "node:fs";
import path from "node:path";
import { gzipSync } from "node:zlib";

// Current reality (2026-08 — ADR 0030, 0043, 0049, 0051): initial chunk ~313 kB
// (react-dom ~181 floor + marked 43 + dompurify 30 + app, including groups and
// local live-Markdown completion), lazy curated-hljs ~74 kB, ~125 kB total gzip.
const MAX_JS_INITIAL = 314_000; // bytes, the entry (index-*) chunk — locks in the lazy hljs split
const MAX_JS_ASSET = 314_000; // bytes, largest single JS chunk
const MAX_JS_TOTAL = 388_000; // bytes, all JS combined
const MAX_CSS_TOTAL = 40_000; // bytes, all CSS combined
const MAX_JS_GZIP = 126_000; // bytes, all JS gzipped — SLO 7, docs/performance.md; ADR 0027 ceiling 140

const assets = path.join("dist", "assets");
if (!fs.existsSync(assets)) {
  console.error("✗ dist/assets missing — run `pnpm build` first");
  process.exit(1);
}

const sizes = fs
  .readdirSync(assets)
  .map((f) => ({ file: path.join(assets, f), bytes: fs.statSync(path.join(assets, f)).size }));

const js = sizes.filter((s) => s.file.endsWith(".js"));
const css = sizes.filter((s) => s.file.endsWith(".css"));
const sum = (xs: { bytes: number }[]) => xs.reduce((n, x) => n + x.bytes, 0);
const kb = (n: number) => `${(n / 1000).toFixed(1)} kB`;

let failures = 0;
const check = (label: string, actual: number, max: number): void => {
  if (actual > max) {
    failures++;
    console.error(`✗ ${label}: ${kb(actual)} > budget ${kb(max)}`);
  } else {
    console.log(`✓ ${label}: ${kb(actual)} (budget ${kb(max)})`);
  }
};

const initial = js.filter((s) => path.basename(s.file).startsWith("index-"));
if (initial.length === 0) {
  failures++;
  console.error("✗ no index-* entry chunk found in dist/assets");
}
check("initial js (index-*)", sum(initial), MAX_JS_INITIAL);
const biggest = js.reduce((a, b) => (a.bytes >= b.bytes ? a : b));
check(`largest js chunk (${path.basename(biggest.file)})`, biggest.bytes, MAX_JS_ASSET);
check("total js", sum(js), MAX_JS_TOTAL);
check("total css", sum(css), MAX_CSS_TOTAL);
const jsGzip = js.reduce((n, s) => n + gzipSync(fs.readFileSync(s.file)).length, 0);
check("total js (gzip)", jsGzip, MAX_JS_GZIP);

if (failures > 0) {
  console.error(`\nbundle budget: ${failures} failure(s) — shrink, don't raise the budget`);
  process.exit(1);
}
