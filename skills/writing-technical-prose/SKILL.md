---
name: writing-technical-prose
description: "Sentence-level and structure conventions for all technical prose: markdown docs, PR descriptions, scratch/design documents, ADRs, README files, commit bodies, code comments, and chat replies. Merges ASD-STE100 Simplified Technical English, ADHD-friendly output shaping, and Hemingway rules, and bans pretentious engineering-blog register (loaded words like seam/leverage/elegant, semicolons, fake-profound framing). Use whenever writing or editing any technical prose or code-speak."
---

# Writing Technical Prose

Apply these rules to every piece of technical prose: markdown files, PR descriptions, scratch and design documents, ADRs, READMEs, issue bodies, commit message bodies, code comments, and chat replies.

The rules merge three sources: ASD-STE100 Simplified Technical English (controlled sentences and words), the i-have-adhd skill (document shape a reader can act on), and Hemingway (cut everything that does not work).

## Sentences

1. Keep sentences short. Maximum 20 words for an instruction, 25 for a description. Split anything longer.
2. Use active voice. Name the actor. Write "The server computes the surface", not "the surface is computed".
3. Write one instruction per sentence. Use the imperative for instructions: "Run the test", not "the test should be run".
4. Use simple tenses: present, past, future. Prefer present tense for how a system behaves.
5. Do not use contractions. Write "do not", "cannot", "it is".
6. Keep paragraphs to one topic and at most 6 sentences.

## Words

1. Prefer the short, common word: "use" not "utilize", "start" not "commence", "about" not "approximately", "so" not "thus".
2. Cut adverbs and hedges: "very", "really", "just", "quite", "possibly", "basically", most "-ly" adverbs. Use a stronger verb instead.
3. No metaphor, idiom, or slang: "knob" → optional feature, "blast radius" → bounded effect, "load-bearing" → critical, "hand-rolled" → written by hand.
4. Use one term per concept and use it every time. Do not vary names for the same thing.
5. Keep noun clusters to 3 words or fewer. Break longer ones with prepositions: "rate accounting for fire windows", not "fire-window rate accounting". Keep the articles ("the", "a") — do not telegraph.

## Document shape

1. Lead with the action or the decision. The first line is what the reader does, or what was decided. Context comes after.
2. Number multi-step work. Each step is one bounded action. If the answer is a command, path, or snippet, it goes first.
3. Cap every list at 5 items. If it grows past 5, split it into named groups ("do first" / "do after", "each call" / "writes").
4. Give concrete estimates, never vague sizes. "About 1 hour" or "2–3 days", not "small" or "some work".
5. End with one concrete next action the reader can do in under two minutes.

## Tone

1. No preamble, no recap, no closing pleasantries. Start with the answer. End when the answer is done.
2. State progress explicitly across turns and in status docs: "Step 3 of 5 done: schema updated. Next: backfill."
3. Report errors matter-of-fact: state cause and fix. Never "uh oh" or "there seems to be a problem".
4. Suppress tangents. Finish the first topic, then offer the second as a separate question.

## Banned register

Do not write in engineering-blog voice: the register that signals seniority instead of transferring information. Its markers are banned as specific words and patterns, not as a vibe.

**Banned words and phrases.** Never write these. Each row gives the replacement move.

| banned | write instead |
| --- | --- |
| seam, surface area, shape (as a design noun), primitive, escape hatch, footgun, sharp edge | Name the concrete thing: the two components and their boundary, the list of endpoints, the actual risk and where it lives. |
| the key insight, the real question, at its core, fundamentally, the story here, this unlocks | Delete the frame. State the fact it was introducing. |
| elegant, clean, robust, powerful, seamless, battle-tested, first-class, best-in-class | State the checkable property: "retries on failure", "no manual steps", "one code path". |
| leverage, delve, journey, landscape, ecosystem, north star, bet (as a design noun) | Use the plain verb or noun: "use", "read", "the other services", "the goal". |
| carve, carve out, wire up, plumb through, bubble up, surface (as a verb) | Say the operation: "move X to Y", "pass X from A to B", "return the error to the caller", "show". |

**Punctuation.**

1. Do not use semicolons in prose. A semicolon joins two claims without stating their relation. Write two sentences, or state the connector: "because", "so", "but".
2. Prefer a period or a comma over an em-dash. Never chain more than one dash pair in a sentence.

**The pointing test.** Every noun that describes the system must point at something you can name: a file, a function, a table, an endpoint, a team. Before you keep an abstract word, replace it with its referent. "The seam between ingestion and storage" becomes "the `parse_upload → write_rows` call in ingest.py". If you cannot make the replacement, you do not know the thing yet. Go find out, or say plainly that you do not know.

## Per-artifact rules

- **PR descriptions**: take the structure from the `writing-pr-descriptions` skill. This skill governs the sentences inside each section.
- **Commit messages**: take the style from the `writing-commits` skill. Apply the sentence rules to the body.
- **Code comments**: repo AGENTS.md rules win (some repos forbid new comments). Where comments are allowed: one short sentence, present tense, says why — not what the code already says.
- **Scratch and design docs**: lead with the decision, end with the next action, give every work item a concrete estimate.
- **Line wrapping**: never hard-wrap prose at a column width. The `writing-unwrapped-prose` skill always applies.

## Exceptions

- Code identifiers, API names, file paths, and quoted command output stay verbatim. Never "simplify" a proper noun or a symbol name.
- Table cells and diagram labels may be fragments.
- Do not rewrite quoted text or another author's words to comply.
- When the reader asks for a full explanation, the body may run long. Keep the sentence rules; add headings so the reader can skim back.
- A destructive step (delete, force push, migration) gets a warning before the instruction, as a command: "Do not run this against production."

## Pre-send check

1. Read only the first line and the last line. Do they say what to do next and what happened? If not, fix them.
2. Delete the first sentence if it announces what the text is about to do. Delete the last sentence if it recaps or asks "anything else?".
3. Split every sentence over 25 words. Cut every adverb and hedge that adds no information.
4. Search for metaphors, contractions, and passive voice. Replace them.
5. Search for semicolons and the banned-register words. Replace each with the concrete referent or delete the frame.
