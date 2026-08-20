#!/usr/bin/env python3
"""Check text against the write-simple rules: NGSL vocabulary + STE mechanics.

Usage:
  check-simple.py FILE...        check files
  echo "text" | check-simple.py  check stdin

Skipped as verbatim: fenced code blocks, backticked spans, URLs, table rows.
A word not on the list is accepted if its first instance is bold
(**word**) — the academic first-use introduction. Later instances may be
plain.

Hard violations (exit 1):
  - word not in the NGSL list and not introduced in bold
  - contraction
  - semicolon in prose
  - sentence over 25 words

Warnings (printed, exit still 0):
  - possible passive voice
  - "-ly" adverb
"""

import re
import sys
from collections import Counter
from pathlib import Path

WORDS = set(
    (Path(__file__).parent.parent / "reference" / "ngsl-words.txt")
    .read_text()
    .split()
)

CONTRACTION = re.compile(r"\b\w+'(t|re|ve|ll|m)\b|\b(it|that|there|he|she|what|who|let)'s\b", re.I)
PASSIVE = re.compile(r"\b(am|is|are|was|were|be|been|being)\s+(\w+ed|shown|given|taken|made|done|seen|known|found|held|kept|left|lost|paid|sent|set|told|built|sold|read|run|put)\b", re.I)
LY_OK = {"only", "early", "daily", "weekly", "monthly", "yearly", "family", "supply", "apply", "reply", "likely", "fly"}


def strip_verbatim(text: str) -> str:
    text = re.sub(r"```.*?```", " ", text, flags=re.DOTALL)
    text = re.sub(r"\$\$.*?\$\$", " ", text, flags=re.DOTALL)
    text = re.sub(r"\$[^$\n]+\$", " ", text)
    text = re.sub(r"`[^`]*`", " ", text)
    text = re.sub(r"https?://\S+", " ", text)
    text = "\n".join(line for line in text.splitlines() if not line.lstrip().startswith("|"))
    return text


def sentences(text: str):
    for line in text.splitlines():
        line = re.sub(r"^\s*(#+|[-*]|\d+\.)\s+", "", line)
        for sent in re.split(r"(?<=[.!?])\s+", line):
            sent = sent.strip()
            if sent:
                yield sent


def main() -> int:
    if len(sys.argv) > 1:
        text = "\n".join(Path(p).read_text() for p in sys.argv[1:])
    else:
        text = sys.stdin.read()
    prose = strip_verbatim(text)

    violations = 0

    bold_spans = [
        m.span(2) for m in re.finditer(r"(\*\*|__)([^*_\n]+)\1", prose)
    ]

    def in_bold(start: int, end: int) -> bool:
        return any(s <= start and end <= e for s, e in bold_spans)

    introduced: set = set()
    bad_words: Counter = Counter()
    for m in re.finditer(r"[A-Za-z']+", prose):
        word = m.group(0).lower().strip("'")
        word = re.sub(r"'s$", "", word)
        if not word or word in WORDS:
            continue
        if in_bold(m.start(), m.end()):
            introduced.add(word)  # first use in bold introduces the term
            continue
        if word in introduced:
            continue
        bad_words[word] += 1
    for word, count in bad_words.most_common():
        print(f"vocab: '{word}' not in NGSL and not introduced in bold (x{count})")
        violations += count

    for match in CONTRACTION.finditer(prose):
        print(f"contraction: {match.group(0)}")
        violations += 1

    for sent in sentences(prose):
        if ";" in sent:
            print(f"semicolon: {sent[:60]}")
            violations += 1
        n = len(re.findall(r"[A-Za-z']+", sent))
        if n > 25:
            print(f"long sentence ({n} words): {sent[:60]}...")
            violations += 1

    for match in PASSIVE.finditer(prose):
        print(f"warn possible passive: {match.group(0)}")
    for token in set(re.findall(r"\b[A-Za-z]+ly\b", prose)):
        if token.lower() not in LY_OK:
            print(f"warn -ly adverb: {token}")

    if violations:
        print(f"\n{violations} violations")
        return 1
    print("clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
