---
name: explain-like-im-chud
description: "Builds single-file HTML explainers for hard code: minimal tjbai-style page, clickable SVG diagrams (pipeline, timelines, or state ladders -- whatever matches the system's shape), real payload snapshots, tight prose. Use when asked to \"explain like I'm chud\", for an \"HTML explainer\", a visual deep-dive of a PR or subsystem, or to help the user grok hard code beyond plain text, PR descriptions, or mermaid diagrams."
---

# Building HTML Explainers

One self-contained HTML file that teaches a hard system by combining three things that never work alone: a spatial diagram, exact data shapes, and tight prose. The reader follows one real artifact through the system — where you are (diagram), what the data looks like right here (payload snapshot), and why this part exists (contract prose).

The reference output style lives in `reference/template.html` — start from it, do not improvise the CSS.

## When this beats other formats

- Text-only explanations dump structure the reader must rebuild in their head.
- Mermaid diagrams show topology but never data.
- PR descriptions show diffs but never flow.

## Let the system's shape choose the diagram family

The template shows a linear pipeline. That is the *default*, not a contract. Ask: what is the hard part of this system?

- **The hard part is what transforms** (request build -> munging -> provider -> response): use the **pipeline** — boxes as stages, numbered hop circles anchor-linked to sections, one payload mutating hop to hop with diff marks.
- **The hard part is when you walk away** (races, cancellation, interrupts, timeouts, partial states): use **streaming timelines** — horizontal time axes, events as circles, dashed commit/cut lines, brackets for windows, a red `x` for cancels, ghosted events for things that never arrive, shaded regions for blind spots. Usually several small timelines beat one big diagram.
- **The hard part is which state you're in**: use a **state ladder** — the *same* data structure snapshotted at N named cut points (S0, S1, S2...), with a one-line predicate that classifies each. This replaces hop-to-hop diffs when the story is "what do we have at this moment?" not "what changed?".

Mix families freely — a timeline section plus a state-ladder `<pre>` is often the right combination. If a rule is deliberately asymmetric (X never *starts* Y but doesn't *kill* a running Y), draw the exception crossing the boundary line and label it; that beats prose.

When you deviate from the pipeline default, say why in one sentence to the user.

## Process

1. **Read the actual code first.** Every mock payload must be shape-accurate — real field names, real event types, real ordering. Never invent a field. If explaining a PR, read the full diff plus the surrounding files it hooks into. Prefer payloads captured from a real run over hand-written ones.
2. **Find the one invariant.** Every good explainer opens by naming the single mental model that tames the system ("every stream leaves the same usage dict; the only question is what's in it when we walk away"). If you cannot name it, you do not understand the system yet.
3. **Design one running example.** A small, concrete scenario that exercises every part. The same example recurs through the entire page, even when the page's spine is timelines or states rather than one traversal.
4. **Pick the tracked artifact.** The one thing whose journey IS the story (an encrypted blob, a request id, a usage dict). Mark it with `<mark>` at every appearance so the eye can follow it.
5. **Pick the diagram family** (above), then **build the page** from `reference/template.html`.
6. **Verify in a real browser** (see Verification).
7. **Deliver** to wherever the user keeps notes/docs for the project, and link it from any related notes doc. If one aspect is referential (tables, formulas, checklists) and another is dynamic, split: keep the HTML for the part that needs to be visual and push the rest to a companion Markdown doc.

## Page structure (default — flex the middle, keep the frame)

1. `<h1>` title, sentence case, plain language.
2. One intro paragraph: the invariant, the trick, and a legend for any marks you use.
3. The first diagram (pipeline, or the first timeline).
4. One short paragraph setting up the running example.
5. `<h2 id="sN">` sections. In pipeline form, one per hop: `N. Sentence-case title -- what this hop means`. In timeline/state form, one per scenario or question ("what happens when the loser is cancelled mid-stream?"). Each section has:
   - a `.who` line: which function/file, one clause of context
   - contract prose: 1-4 sentences, what shape goes in, what comes out, what is guarded
   - a `<pre>` payload snapshot and/or a section-local SVG
   - optionally one "what is lost / why acceptable" or "ordering is load-bearing" note
6. `<hr>`, then 2-4 closing paragraphs: cross-cutting concerns (concurrency model, why local correctness composes, the failure story). Bold lead-in phrase, no headers. For many-failure-mode systems, a funnel framing closes well: "M ways to leave, collapsing to N exits."

Always name the failure story explicitly: the worst case, and why degraded mode is a tradeoff, not a bug.

## Payload discipline

- Every payload shape comes from real code or a real run. Never invent a field.
- `<mark>` = the tracked artifact, every single time it appears, including in prose.
- **Mutation form** (pipeline): show the payload at every hop, elide unchanged regions with `[ ...unchanged from N ]`. `<span class="add">` = added (green `+`), `<span class="del">` = removed (red strikethrough `-`), `<span class="cm">` = inline comment (`// stage 4: restored from cache`). The last hop's output must visibly become the first hop's input — close the loop.
- **Snapshot form** (state ladder): show the same structure at each named cut point in one `<pre>`, label each state, and give the predicate that classifies it. `del` styling can flag the alert-worthy loss case.

## Style rules (non-negotiable, regardless of diagram family)

- **Palette and type**: exactly the template's — `#e8e8e8` background, `#444` text, `#222` headings, `#3273dc` links, `#f2f2f2` code blocks, Inter, ~760px column, ~30 lines of CSS total. No dark theme, no syntax rainbow, no badges, no shadows, no border-radius beyond 3px.
- **ASCII only.** No middle dots, em dashes, arrows, or ellipses in the source: use `,` / `--` / `->` / `...`. Check with `perl -CSD -ne 'print if /[^\x00-\x7F]/' file.html` — output must be empty.
- **Disable font ligatures** (`font-variant-ligatures: none; font-feature-settings: "calt" 0, "liga" 0;`) or Inter silently re-renders `->` as an arrow glyph.
- **Sentence-case headers**; lowercase is fine only for code identifiers in diagram box labels.
- **No JavaScript.** Anchor links only.
- **Prose**: writing-technical-prose rules apply. Short sentences. Name functions, files, and fields directly. Say what is load-bearing and what breaks if you reorder it. Teacher-mode spirit: state what each part loses and why that is a tradeoff, not a bug.

## SVG rules

- Plain: `#f2f2f2` fill, `#999` 1px stroke boxes, `#888` 1.2px arrows/axes with a small triangle marker, `#3273dc` numbers in circles and accent lines.
- Box interior: title at y+22 to y+25, subtitle lines 16-20px apart, 12px/10.5px font sizes.
- Vertical gaps between rows: 40-55px minimum. Cramped kills it.
- Pipeline: route arrows through gutters between columns — never through a box; long return paths go around the outside; numbered circles sit on their arrow's midpoint and anchor-link to the matching section.
- Timelines: events as small circles on the axis, labels alternating above/below to avoid collisions; dashed vertical lines for commit/interrupt moments; green brackets for grace/capture windows; ghost (reduced-opacity) events for things that never happen; shade regions where something accrues invisibly.
- Size the viewBox to the content; no dead space below.

## Verification (required before delivering)

No browser automation. Verify statically, then hand the visual pass to the user:

1. ASCII: `perl -CSD -ne 'print if /[^\x00-\x7F]/' file.html` — output must be empty.
2. Geometry pass on every SVG, by coordinates: each arrow path's endpoints against the box rects (arrows route through gutters, never through a box), vertical gaps between box rows >= 40px, numbered circles on their arrow midpoints, viewBox sized to the content with no dead space below.
3. Sanity-check `<pre>` blocks for lines that will overflow ~90 columns at the template's font size; wrap or elide them.
4. Open the finished page in the user's default browser (`open <file>` on macOS) and ask them to flag label collisions, cramped rows, or dead whitespace; fix what they report.

Before declaring done, confirm the delivered file is actually tracked by git (`git status --ignored -- <file>`) — whitelist-style `.gitignore` files silently drop non-`.md` docs; add a scoped exception like `!docs/usage/*.html` if needed.
