---
name: explain-like-im-monkey
description: "Helps the user grok a big PR, diff, or unfamiliar subsystem by talking through it like a human and showing whatever makes it click: annotated file layouts, call paths, ASCII diagrams, timelines, before/after, small code excerpts. Delivered as a plain Markdown note. Use when asked to \"explain like I'm monkey\", for a \"monkey explainer\", \"monkey brain this\", \"help me monkey brain X\", or when the user says an explanation is still too complicated and wants visuals without the HTML explainer."
---

# Monkey explainers

The user is staring at a big diff and cannot see the shape of it. Talk to them like a colleague at a whiteboard: what is this thing, where does it live in the tree, what path does a request take through it, what should they actually look at. Show, don't lecture.

Plain Markdown, one file. Not the HTML explainer (`explain-like-im-chud`).

## How to do it

1. Read the code, not the PR description. The diff plus the files it hooks into. Every claim points at a file or function you read.
2. Figure out the shape. Usually: which files are new vs touched, which ones are the real work vs plumbing/generated, and what the runtime path is through them.
3. Write it the way you would explain it out loud. Short paragraphs. Name files and functions directly. Say what it does and what it does not do, up front.
4. Use whatever visual fits the thing you are explaining, only where prose would be worse:
   - annotated file tree, with a one-line job per file and `(NEW)` markers, for "where does this live"
   - call path or stack trace (`a() → b() → c()`, with the file next to each) for "how does a request get there"
   - box diagram with labeled branches for a decision
   - `t0 … tN` timeline for anything with a lifetime (a row, a token, a session)
   - before / after columns for anything the caller sees
   - a 3–10 line code excerpt with `◀──` comments when the real code is the clearest picture
5. If part of it is built but nothing calls it yet, say so. People overestimate blast radius.
6. End with the two or three things worth actually reading, and any open questions the diff leaves you with.
7. Sanity-check the claims before delivering. For a big or security-relevant diff, spawn a Task reviewer with the doc and the diff to check factual claims (return values on the empty path, "always" vs "when configured", line references). Fix what it finds.
8. Write to the user's notes location for the project as `<topic>-monkey.md`. Don't summarize the doc back in chat; say what the reviewer corrected, if anything.

## Formatting

- Every diagram, tree, and excerpt goes in a fenced ```text (or language) block. Never 4-space indented blocks: some renderers collapse them into one line, and a block after a list gets swallowed as list continuation.
- Box-drawing chars `┌─┐│└┘ ▼ ▲ ◀── →`, under 90 columns. Several small diagrams beat one big one.
- No fixed section list. Headings where they help the reader jump around, not to fill a template.
- The `style` skill's writing rules apply to the prose.
