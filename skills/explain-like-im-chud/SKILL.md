---
name: explain-like-im-chud
description: "Builds single-file HTML explainers for hard code: minimal tjbai-style page, clickable SVG pipeline diagram, one mock payload evolving stage by stage with diff marks. Use when asked to \"explain like I'm chud\", for an \"HTML explainer\", a visual deep-dive of a PR or subsystem, or to help the user grok hard code beyond plain text, PR descriptions, or mermaid diagrams."
---

# Building HTML Explainers

One self-contained HTML file that teaches a hard system by combining three things that never work alone: a spatial diagram, exact data shapes, and tight prose. The reader watches one concrete payload mutate through every stage of the system.

The reference output style lives in `reference/template.html` — start from it, do not improvise the CSS.

## When this beats other formats

- Text-only explanations dump structure the reader must rebuild in their head.
- Mermaid diagrams show topology but never data.
- PR descriptions show diffs but never flow.

The explainer shows all three at once: where you are (diagram), what the data looks like right here (payload snapshot), and why this hop exists (contract prose).

## Process

1. **Read the actual code first.** Every mock payload must be shape-accurate — real field names, real event types, real ordering. Never invent a field. If explaining a PR, read the full diff plus the surrounding files it hooks into.
2. **Find the one invariant.** Every good explainer opens by naming the single mental model that tames the system ("format X is the interlingua every stage converts to and from"). If you cannot name it, you do not understand the system yet.
3. **Design one running example.** A small, concrete scenario (one user turn, one tool call, one image) that exercises every stage. The same example flows through the entire page.
4. **Pick the tracked artifact.** The one thing whose journey IS the story (an encrypted blob, a request id, a lock). Mark it with `<mark>` at every appearance so the eye can follow it.
5. **Build the page** from `reference/template.html`.
6. **Verify in a real browser** (see Verification).
7. **Deliver** to wherever the user keeps notes/docs for the project, and link it from any related notes doc.

## Page structure

In order, nothing else:

1. `<h1>` title, sentence case, plain language.
2. One intro paragraph: the invariant, the trick, and the legend for diff marks.
3. The SVG diagram: every stage a box, every hop a numbered circle that is an `<a href="#sN">` anchor.
4. One short paragraph setting up the running example.
5. One `<h2>` section per hop: `N. Sentence-case title -- what this hop means`. Each section has:
   - a `.who` line: which function/file, one clause of context
   - contract prose: 1-4 sentences, what shape goes in, what comes out, what is guarded
   - a `<pre>` payload snapshot with diff marks
   - optionally one "what is lost / why acceptable" or "ordering is load-bearing" note
6. `<hr>`, then 2-4 closing paragraphs: cross-cutting concerns (concurrency model, why local correctness composes, the failure story). Bold lead-in phrase, no headers.

## Payload evolution discipline

- Show the payload at every hop, but elide unchanged regions with `[ ...unchanged from N ]` comments.
- `<span class="add">` = line added by this stage (renders green with a `+`).
- `<span class="del">` = line removed by this stage (renders red strikethrough with a `-`).
- `<span class="cm">` = inline comment explaining a line (`// stage 4: restored from cache`).
- `<mark>` = the tracked artifact, every single time it appears, including in prose.
- The last hop's output must visibly become the first hop's input — close the loop explicitly.

## Style rules (non-negotiable)

- **Palette and type**: exactly the template's — `#e8e8e8` background, `#444` text, `#222` headings, `#3273dc` links, `#f2f2f2` code blocks, Inter, ~760px column, ~30 lines of CSS total. No dark theme, no syntax rainbow, no badges, no shadows, no border-radius beyond 3px.
- **ASCII only.** No middle dots, em dashes, arrows, or ellipses in the source: use `,` / `--` / `->` / `...`. Check with `perl -CSD -ne 'print if /[^\x00-\x7F]/' file.html` — output must be empty.
- **Disable font ligatures** (`font-variant-ligatures: none; font-feature-settings: "calt" 0, "liga" 0;`) or Inter silently re-renders `->` as an arrow glyph.
- **Sentence-case headers**; lowercase is fine only for code identifiers in diagram box labels.
- **No JavaScript.** Anchor links only.
- **Prose**: writing-technical-prose rules apply. Short sentences. Name functions, files, and fields directly. Say what is load-bearing and what breaks if you reorder it. Teacher-mode spirit: state what each hop loses and why that is a tradeoff, not a bug.

## SVG diagram rules

- Plain: `#f2f2f2` fill, `#999` 1px stroke boxes, `#888` 1.2px arrows with a small triangle marker, `#3273dc` numbers in circles.
- Box interior: title at y+22 to y+25, subtitle lines 16-20px apart, 12px/10.5px font sizes.
- Vertical gaps between rows: 40-55px minimum. Cramped kills it.
- Route arrows through gutters between columns — never through a box. Long return paths go around the outside.
- Numbered circles sit on their arrow's midpoint and anchor-link to the matching section.
- Size the viewBox to the content; no dead space below.

## Verification (required before delivering)

Playwright blocks `file://`, so:

```bash
python3 -m http.server 8734 --directory <dir-with-html> &
```

Then with a real browser (a Playwright browser skill/tool if available): navigate, screenshot at top / middle / bottom, and view each screenshot checking for: arrows crossing boxes, cramped rows, ligature glyphs, `<pre>` overflow, dead whitespace. Fix and re-screenshot until clean. Kill the server and close the browser when done.
