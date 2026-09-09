---
name: writing-simple
description: "Writes prose in simple technical English: ASD-STE100 Simplified Technical English sentence rules, plain NGSL words for plain ideas, precise technical terms where they are exact, and bold introduction of unfamiliar terminology. Verified with a bundled checker script. Triggers on: write simple, write like STE, STE, NGSL, simplified technical english. Use whenever the user asks for simple, STE, or NGSL-constrained output. This is the default prose register per the style skill."
---

# Write Simple

Write in simple technical English. Two layers:

1. **STE sentence mechanics** (from ASD-STE100 Simplified Technical English). Hard rules.
2. **Plain words, precise terms.** The NGSL list in `reference/ngsl-words.txt` (NGSL 1.2 plus 52 supplementary words) is the guide for ordinary wording. Technical terms are allowed when they are the exact name for the thing.

A checker script enforces the mechanics and flags words off the NGSL list for review. Writing is not done until the mechanics pass and you have reviewed each flagged word.

## Sentences

1. Keep sentences short. Maximum 20 words for an instruction, 25 for a description. Split anything longer.
2. Use active voice. Name the actor. Write "The server computes the surface", not "the surface is computed".
3. Write one instruction per sentence. Use the imperative for instructions: "Run the test", not "the test should be run".
4. Use simple tenses only: present, past, future. Prefer present tense for how a system behaves. Do not use perfect or progressive forms.
5. Do not use contractions. Write "do not", "cannot", "it is".
6. Do not use semicolons. Write two sentences, or state the connector: "because", "so", "but".
7. Keep paragraphs to one topic and at most 6 sentences.

## Words

Three principles decide every word choice.

1. **Write for a working engineer.** Assume the reader knows general programming and engineering vocabulary, common tools, and well-known products. Do not explain or decorate those.
2. **Plain word when the plain word is exact. Technical term when it is.** For an ordinary idea, use the NGSL word: "use" not "leverage", "start" not "initiate". For a precise idea, use the precise term (`webhook`, `idempotent`, `mutex`, `rebase`, `migration`). A vague paraphrase of a technical term is worse than the term. STE itself allows technical names and verbs outside its dictionary for this reason.
3. **Introduce terminology once, then use one name per concept.** Bold the first use of a term the reader may not know. That means domain vocabulary (an Auctor term like **portal space**), a name this document coins, or a concept from another field. After the bold first use, write it plain and never vary the name. Do not bold general engineering terms, product names, or anything the reader already knows.

Rules that follow from these:

- Cut adverbs and hedges: "very", "really", "just", "quite", most "-ly" adverbs. Use a stronger verb instead.
- No metaphor, idiom, or slang. Replace each with the literal meaning.
- No engineering-blog register: "elegant", "robust", "seamless", "leverage", "the key insight", "at its core". Name the concrete referent instead.
- Use each word as one part of speech with one meaning.
- Keep noun clusters to 3 words or fewer. Break longer ones with prepositions. Keep the articles ("the", "a").
- A simpler word must not change what the sentence claims. Keep the plain meaning.

## Warnings and instructions

1. Put a warning before the instruction it protects, as a command: "Do not run this against production."
2. Start a warning with the condition or the command, never with background.

## Exceptions

- Code identifiers, API names, file paths, commands, and quoted output stay verbatim. Wrap them in backticks so the checker skips them. Use backticks only for real code, never to make a plain word pass.
- Table cells and diagram labels may be fragments.
- Do not rewrite quoted text or another author's words to comply.

## Verify before sending

Run the checker on what you wrote:

```
echo "the text" | python3 scripts/check-simple.py
```

or

```
python3 scripts/check-simple.py draft.md
```

It skips backticked spans, fenced code blocks, LaTeX math spans (`$...$` and `$$...$$`), URLs, and table rows. It exits 1 on any hard violation: a contraction, a semicolon, or a sentence over 25 words. It prints `warn` lines for possible passive voice, "-ly" adverbs, and words off the NGSL list. A word introduced in bold stops being flagged after its first use.

Treat each `warn vocab` line as a question, not an error. Keep the word if it is the exact technical term or a name the reader knows. Replace it if a plain word says the same thing. Bold its first use if it is terminology the reader may not know. Fix each hard violation and run again until it prints "clean".
