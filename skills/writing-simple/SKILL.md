---
name: writing-simple
description: "Writes prose in a controlled simple English: ASD-STE100 Simplified Technical English sentence rules plus a closed NGSL vocabulary (the 2809 highest-frequency English words), verified with a bundled checker script. Triggers on: write simple, write like STE, STE, NGSL, simplified technical english. Use whenever the user asks for simple, STE, or NGSL-constrained output. This is the default prose register per the style skill."
---

# Write Simple

Write in controlled simple English. Two layers, both hard rules:

1. **STE sentence mechanics** (from ASD-STE100 Simplified Technical English).
2. **Closed NGSL vocabulary**: every word of prose must appear in `reference/ngsl-words.txt` (NGSL 1.2 plus the 52 supplementary words, one lowercase word form per line).

A checker script enforces both. Writing is not done until it passes.

## Sentences

1. Keep sentences short. Maximum 20 words for an instruction, 25 for a description. Split anything longer.
2. Use active voice. Name the actor. Write "The server computes the surface", not "the surface is computed".
3. Write one instruction per sentence. Use the imperative for instructions: "Run the test", not "the test should be run".
4. Use simple tenses only: present, past, future. Prefer present tense for how a system behaves. Do not use perfect or progressive forms.
5. Do not use contractions. Write "do not", "cannot", "it is".
6. Do not use semicolons. Write two sentences, or state the connector: "because", "so", "but".
7. Keep paragraphs to one topic and at most 6 sentences.

## Words

1. Every word of prose must be on the list in `reference/ngsl-words.txt`. If a word is not in the file, do not write it. Find the closest allowed word or restructure the sentence. Do not leave the idea out — say it with the words you have.
2. Keep the plain meaning. A simpler word must not change what the sentence claims.
3. Cut adverbs and hedges: "very", "really", "just", "quite", most "-ly" adverbs. Use a stronger verb instead.
4. No metaphor, idiom, or slang. Replace each with the literal meaning.
5. Use one term per concept and use it every time. Do not vary names for the same thing.
6. Use each word as one part of speech with one meaning.
7. Keep noun clusters to 3 words or fewer. Break longer ones with prepositions. Keep the articles ("the", "a").

## Warnings and instructions

1. Put a warning before the instruction it protects, as a command: "Do not run this against production."
2. Start a warning with the condition or the command, never with background.

## Exceptions

- Code identifiers, API names, file paths, commands, and quoted output stay verbatim. Wrap them in backticks so the checker skips them. Use backticks only for real code — never to make a plain word pass the checker. If a word fails the check, find an allowed word or restructure the sentence.
- New terms and proper nouns (people, products, places) are allowed, but you must introduce them: make the first instance bold (`**Datadog**`), then write it plain after that. The checker accepts a word that is not on the list only after a bold first use.
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

It skips backticked spans, fenced code blocks, LaTeX math spans (`$...$` and `$$...$$`), URLs, and table rows. It exits 1 on any hard violation: a word not on the NGSL list (unless its first instance is bold), a contraction, a semicolon, or a sentence over 25 words. It prints `warn` lines for possible passive voice and "-ly" adverbs — fix them unless they are false matches. Fix each violation and run it again until it prints "clean".
