---
name: explain-like-im-monkey
description: "Writes plain-language Markdown explainers for hard code, PRs, and PR stacks: modules black-boxed by responsibility, ASCII flow and lifecycle diagrams, a 'what is live' table, a 'what to actually look at' table, and open questions. Verified against the code by a separate reviewer before delivery. Use when asked to \"explain like I'm monkey\", for a \"monkey explainer\", \"monkey brain this\", \"help me monkey brain X\", or when the user says an explanation is still too complicated and wants visuals without the HTML explainer."
---

# Monkey explainers

A monkey explainer is one Markdown file that lets the reader judge a change without reading every line of the diff. It black-boxes modules by their one job and draws the flow in ASCII. It says what is live in production right now versus what is only built. It ends with the questions the reader should carry into review.

It is not the HTML explainer (`explain-like-im-chud`). No HTML, no SVG, no template CSS. Plain Markdown that renders in any viewer and diffs in git.

## When to write one

- The user says a prior explanation is "still too complicated".
- The user needs to review a PR or a position in a PR stack that touches code they own but did not write.
- The user is missing context about a neighboring package and needs it filled in without reading that package.
- The user asks how several PRs in a stack relate.

## Process

1. Read the code, not the PR description. Read the full diff and the files it hooks into. Every claim in the doc must point at a file, function, or line range you read.
2. Decide the one thing this change does and the one thing it does not do. Write both in the opening lines.
3. List every module the diff touches or depends on. Give each one job in one line. This is section 0.
4. Find the runtime path. Follow one concrete artifact (a credential, a request id, a row) from creation to cleanup. Draw it.
5. Separate built from live. For each piece, ask: does any production caller reach this today? If not, say so. Readers over-estimate blast radius when they cannot see this.
6. Write the doc from the skeleton below.
7. Verify with a separate reviewer (see Verification). Fix what it finds. Do not skip this.
8. Deliver to wherever the user keeps notes for this project, named `<topic>-monkey.md`. For a stack, `pr<N>-monkey.md` and cross-reference the previous one.

## Skeleton

```markdown
# <Thing> for monkeys — <short topic>

<Where it sits, in one line. What it does, in one line. What it does NOT do, in one line.>
<If part of a series: "Read prN-monkey.md §0 first for the X black box.">

## 0. Black boxes

Treat each as a thing with one job. Only open it if a verdict depends on it.

    pkg/a/                     THE <ROLE>. <one line: what it owns>
      file.py                  <one line job>
      new_file.py   (NEW)      <one line job>
    pkg/b/                     THE <ROLE>. <one line>
    host/x/factory.py          glue: <what it constructs, what it registers>

Rule of thumb: <one sentence on which layer owns what>.

## 1. Before / after
<side-by-side ASCII: what the caller or model saw before, what it sees now.
State that this is the entire externally visible delta if it is.>

## 2. <The hook / the entry point>
<ASCII: where the new code sits in the existing loop. Mark regressions with ◀── and a label.>

## 3. <The decision / the transform>
<ASCII box: inputs in at the top, outputs out at the bottom, branches labeled.>

## 4. <Lifecycle>
<t0 … tN timeline of the tracked artifact. Who creates, who reads, who refreshes, who deletes.>

    LATER (pos N, #1234): <how a later PR changes this story>

## N. What is live at this position

| built | live in prod |
|---|---|
| <thing> | yes — <who calls it> |
| <thing> | yes — but <caveat> |
| <thing> | NO (pos N) |

So at this position the only observable change for real users is <X>.

## N+1. What to actually look at

| If you care about | Look at | Skip |
|---|---|---|
| your loop | `path.py` `fn` | `other.py` (it is a strict parser) |
| the public contract | `types.py` `TypeName` | the generated mirrors |
| the fragile bit | `file.py` (60 lines) | — |

## N+2. Questions this should leave you with

1. <open design question, not an answer>
2. ...
```

Flex the middle. Keep the frame: section 0, the live table, the look-at table, the questions.

## Diagram rules

- ASCII only inside the diagrams: `┌─┐│└┘`, `▼`, `▲`, `◀──`, `→`. Keep every diagram under 90 columns.
- One diagram per idea. Several small diagrams beat one big one.
- Annotate with arrows and short labels: `◀── H.1 lives here`, `← the I/O (pos 7+)`.
- Before/after columns for anything the caller sees. Timelines (`t0 … t5`) for anything with a lifetime. Boxes with labeled branches for anything that decides.
- A `LATER (pos N, #PR):` box wherever a later change alters the story. The reader must hold the model for this position, not the final one.

## Prose rules

- Terse, declarative, informal. Short sentences. Name files and functions directly.
- One concrete analogy per mechanism, when a real one exists. Examples: "think `dict.setdefault` with a lock and an LRU", "a rulebook with an empty roster", "the referee, with no players yet". Never a forced one.
- Bold the one-sentence version of each mechanism, once.
- Minimal code. Inline expressions like `ref = "access_" + uuid5(...)` and small dict or list literals. No code blocks longer than five lines. The doc does not restate the diff.
- Call out fragile parts as fragile and say why: "mutable dict that is never reset, stash-then-never-consume leaks entries".
- Where a design choice is debatable, name it and move on. The questions section collects them.
- The `style` skill's writing rules apply outside the diagrams.

## Explaining relations between several PRs

When the ask is "how do 5, 6, and 7 relate", use chat form instead of a file unless the user asks for a file:

1. One ASCII box per PR, labeled with the single question it answers, joined in runtime order. Note when ship order differs from runtime order and why.
2. One paragraph per PR, each ending with `What's live after N:`.
3. A closing "one line each" mnemonic.

## Verification (required)

The first draft will overclaim. Before delivering, spawn a separate reviewer (Task subagent) with the doc and the diff and ask it to check every factual claim against the code. Give it the doc path, the branch or PR, and this checklist:

- Return values on the empty path (does the hook return `None` or a default object?).
- Scope words: "every call" versus "every fresh batch", "always" versus "when configured".
- Security claims. An identifier is not a capability. "The model cannot forge X" is only true if X is unguessable, not merely opaque.
- Hash and fingerprint inputs: list exactly what is included and excluded, from the code.
- "Only observable change is X": enumerate the other changes and confirm none are user-visible.
- Line references still point at the code they describe.

Ask the reviewer to return each wrong claim with the correct statement and the file and line that proves it. Fix the doc in place. If the reviewer finds a bug the doc did not mention, add it.

## Delivery

Write the file to the user's notes location for the project. Tell the user which claims the reviewer corrected. Do not summarize the doc back in chat. Offer the next position in the stack.
