# Technical writing

## Default register

The `writing-simple` skill is the default register for all prose: STE sentence rules plus the closed NGSL vocabulary. Load it whenever writing prose.

Checker policy:

- Durable prose (docs, scratch notes, ADRs, READMEs, status files): run `scripts/check-simple.py` until clean. Mandatory.
- Chat replies, commit bodies, PR body prose: follow the sentence and vocabulary rules by hand. Running the checker is best-effort, not required.

## Mechanics

- Never hard-wrap prose at a column width. One paragraph, one line. Unwrap hard-wrapped paragraphs you touch.
- Never write `--` in place of an em-dash. Avoid em-dashes generally: use a period or a comma.
- No semicolons. Write two sentences, or state the connector: "because", "so", "but".
- Backticks are for real code only: identifiers, paths, commands, table names, flags. Never wrap an ordinary word in backticks.
- Bold sparingly: first use of a new term or proper noun, per writing-simple.

## Banned register

Never write engineering-blog voice — the register that signals seniority instead of transferring information:

- elegant, clean, robust, powerful, seamless, battle-tested, first-class, leverage, delve, journey, ecosystem, north star
- "the key insight", "the real question", "at its core", "fundamentally", "this unlocks", "the story here"
- seam, surface area, shape (as a design noun), slice, workstream, vertical (as work nouns), primitive, footgun, escape hatch
- carve out, wire up, plumb through, bubble up, surface (as a verb)

Replace each with its concrete referent: the file, function, table, endpoint, behavior, or tradeoff. If you cannot name the referent, you do not know the thing yet — go find out or say you do not know.

## Shape

- Lead with the decision or the action. No preamble, no recap, no closing pleasantries.
- Number multi-step work. If the answer is a command, path, or snippet, it goes first.
- Report errors matter-of-fact: cause, then fix.
- Simple. Token-efficient. Not oversteered.
