---
name: style
description: "The global style index for everything written: code, Python, commits, PR titles and descriptions, and technical prose. Sets the default register and the de-slop bar. Apply on the first pass, not as a cleanup pass. Use whenever writing or cleaning code, committing, writing PRs, or writing any prose. Triggers on: style, slop, de-slop, deslop, clean up, tidy, commit, PR, prose, my style."
---

# Style

Index skill. Before producing an artifact, read the matching reference file. Apply it on the first pass — a "de-slop" or "clean this up" request from the user means this skill failed.

| Producing | Read |
| --- | --- |
| Any code | [reference/coding.md](reference/coding.md) |
| Python | [reference/python.md](reference/python.md), after coding.md |
| Git commits | [reference/commits.md](reference/commits.md) |
| PRs: titles and descriptions | [reference/pr.md](reference/pr.md) |
| Prose: docs, ADRs, scratch notes, chat, comments | [reference/writing.md](reference/writing.md) |

When the user says "de-slop" or "clean up", apply coding.md and python.md.

## Always

- The default prose register is the `writing-simple` skill (STE sentences, closed NGSL vocabulary). Load it for any durable prose. Details and checker policy: [reference/writing.md](reference/writing.md).
- Never hard-wrap prose at a column width. Write each paragraph as one line; let the renderer soft-wrap. When editing hard-wrapped text you touch, unwrap it. Exceptions: code, tables, YAML/TOML/JSON, formats that genuinely require wrapping.
- Zero inline comments in code by default. See coding.md for the rare exceptions.
- Smallest accurate diff. Never reformat lines you did not change.

## Amending this skill

When the user nudges on style during a session, this skill is stale or wrong. Do not just comply and move on.

**Trigger.** Two or more corrections on the same theme in one session, or one correction that contradicts a rule written here.

**Action.** At the next natural pause (end of the task, before the final report):

1. Propose a concrete amendment as a diff to the right reference file. Quote the user's correction verbatim as evidence, typos included.
2. For a theme no reference file covers, propose a new `reference/<topic>.md` plus an index row above.
3. Keep it minimal: one rule per correction pattern. No restructuring, no rewriting adjacent rules.
4. Apply only after the user approves.
5. `~/.config/agents/skills` is a git repo. Commit each amendment separately with a lowercase subject: `style: <rule added or changed>`.

Never propose an amendment for a one-off, context-specific instruction. Amend only for corrections that would apply to future sessions.
