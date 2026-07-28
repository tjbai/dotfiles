---
name: running-research-spikes
description: Runs parallel Exa-backed research spikes and writes one report per spike plus an overview into a target directory. Use when the user asks for a research spike, research pass, prior-art check, or literature/landscape survey, especially when they mention EXA_API_KEY.
---

# Running research spikes

Fan out parallel Task subagents — one per spike — each armed with the Exa curl recipe. Each spike writes its own Markdown report into the target directory; you write an overview that synthesizes them.

## Setup

Verify the key exists without exposing it (workdir = the directory containing `.env`):

```bash
rg -c "EXA_API_KEY" .env
```

A count of 1 is enough. Never print the value. If the key is missing or the API rejects it, fall back to `web_search` + `read_web_page` and say so.

Resolve the output directory. The user normally points at one; if they mention scratch, load `using-scratch` first. Check for existing docs there so new spikes extend rather than duplicate.

## Fan out

Launch all spikes in one turn, 3–5 Task subagents. Partition by source type or domain — official docs, academic literature, practitioner writeups, discussion, products — not by keyword.

Each spike prompt:

```
You are a research agent. Pure research — no code changes; write ONLY your designated output file.
Today is <month year>.

## Context
<shared paragraph: the system, finding, or question under investigation>

## Your spike: <NAME>
<4–6 numbered sub-questions, seeded with anchor papers/repos/docs to
chase; verify against primary sources, add distinct ones you find>

## Tools
You have web_search and read_web_page. You also have an Exa API key:
export EXA_API_KEY=$(grep '^EXA_API_KEY=' <ABS_PATH>/.env | cut -d= -f2-)

curl -s https://api.exa.ai/search \
  -H "x-api-key: $EXA_API_KEY" -H "Content-Type: application/json" \
  -d '{"query":"...","numResults":10,"type":"auto","contents":{"text":{"maxCharacters":2000}}}'

Exa is good at semantic queries. Fan out multiple phrasings; read the
best hits in full with read_web_page. If the key is empty, use web_search.

## Quality bar
Primary sources only — original papers, official docs, first-person
engineering posts. No SEO farms, listicles, or vendor marketing.

## Deliverable
Write <DIR>/<spike-name>.md: title + 2–3 sentence intro, one ### section
per finding with inline source links, closing tradeoffs/implications
paragraph. Plain prose, under ~90 lines. A URL for every claim; verbatim
quotes where load-bearing. Flag what you could not verify; say explicitly
if you find NOTHING — that is itself a finding.

## Return
The file path, topics covered, and the URLs cited.
```

Useful Exa body tweaks per spike: `"category":"research paper"` for academic, `"category":"personal site"` for blogs, `"includeDomains":["news.ycombinator.com"]` (or reddit/x.com) for discussion, `"startPublishedDate"` when recency matters.

## Overview

After the spikes return, read their files and write `<DIR>/overview.md` yourself — no merge subagent. Organize by theme, not by spike: convergent findings up top, per-theme sections keeping the key quotes/numbers/URLs, explicit gaps ("nobody measured X"), and a short list of what to read first. Then report the headlines to the user in a few sentences and point at the directory.
