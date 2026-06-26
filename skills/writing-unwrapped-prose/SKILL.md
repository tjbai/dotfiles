---
name: writing-unwrapped-prose
description: "Enforces never manually wrapping prose to a fixed column width. Use whenever writing or editing any prose: markdown, docs, PR descriptions, commit bodies, comments, scratch notes, ADRs, or chat replies."
---

# Writing Unwrapped Prose

Never insert manual line breaks to wrap text at a fixed column width (72, 80, 100, etc.). Let the renderer or editor soft-wrap.

## Rules

- Write each paragraph as a single continuous line. Do not hard-wrap at a column boundary.
- Use a newline only for a real structural break: a new paragraph, a list item, a heading, a blockquote line, or a code line.
- This applies everywhere prose is authored: markdown files, PR/issue bodies, commit message bodies, code comments, docstrings, scratch/`.md` notes, ADRs, and chat responses.
- When editing existing manually-wrapped text, unwrap the paragraphs you touch (join the broken lines back into one) rather than preserving the old wrapping.

## Exceptions

- Code blocks and code: keep existing line structure; respect the language's formatter.
- Tables, YAML/TOML/JSON, and other structured formats: follow their own line rules.
- Hard-wrap only when a specific tool or format genuinely requires it (e.g. a linter that enforces it), and say so.
