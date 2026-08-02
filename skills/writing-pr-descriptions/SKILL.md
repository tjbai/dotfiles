---
name: writing-pr-descriptions
description: Writes detailed pull request descriptions using the team's preferred template. Use when creating, updating, or polishing PR bodies, especially when the user asks for the default PR template.
---

# Writing PR Descriptions

Use this skill when creating or rewriting a pull request body for the team.

The preferred PR description style is a narrative, reviewer-friendly template with a concise summary first, then structured detail. It should explain what changed, why the changes belong together in one PR, what reviewers should watch, what is intentionally out of scope, and how the change was validated.

## Workflow

1. Inspect the branch diff and commit list against the intended base branch.
2. If the user mentions screenshots or media, upload them as GitHub user attachments when possible and embed them inline with Markdown image syntax.
3. Write the PR body with the sections below, omitting sections that truly do not apply.
4. Prefer product/domain language from the code and issue context over generic implementation language.
5. Keep the body thorough but reviewable: enough detail for reviewers to orient quickly, not a file-by-file changelog.

## Template

```markdown
## Summary

<Open with what the PR does: the behavior it adds or changes, stated as a plain fact. Then one or two paragraphs: why this branch exists, what it deliberately trades off, and stacking context when relevant.>

<If relevant, state rollout status, dogfooding intent, or feature-gate context.>

## ELI5

<One short paragraph describing the relevant behavior as it works today, in plain language a non-expert could follow.>

<One or two short paragraphs describing how the behavior changes after this PR. Frame it as the question the system now asks and what happens for each answer, including the important edge cases. Avoid implementation jargon; use product/runtime terms.>

## Screenshots

### <Screenshot name>

![<alt text>](<github-user-attachment-url>)

## What changed

### <Area 1>

<Short paragraph explaining the area.>

- <specific behavior / codepath / UX change>
- <specific behavior / codepath / UX change>
- <specific behavior / codepath / UX change>

### <Area 2>

<Short paragraph explaining the area.>

- <specific behavior / codepath / UX change>
- <specific behavior / codepath / UX change>

## Rollout / risk notes

Main risk areas to watch during dogfooding:

1. **<Risk area>**
   - <What could go wrong, why it is bounded, and what to watch.>
2. **<Risk area>**
   - <What could go wrong, why it is bounded, and what to watch.>

## Not in this PR

Explicitly deferred:

- <non-goal / follow-up>
- <non-goal / follow-up>
- <non-goal / follow-up>

## Test coverage / validation

Adds focused coverage for:

- <test / behavior area>
- <test / behavior area>

Recent local validation:

- `<command>`
- `<command>`

Notes:

- <known warning, failing unrelated check, or CI/source-of-truth caveat>
```

## Section guidance

### Summary

- Open with what the PR does: "<Subject> now <behavior>" or "This PR makes Y...". Describe the change itself, never its position in a plan or taxonomy.
- Name the branch's scope and the important tradeoff.
- Explain the resulting user/product/runtime behavior in plain language.
- Mention stacking, rollout path, or dogfooding status when relevant.

### ELI5

- Write for a non-expert: explain the behavior before and after this PR in plain language.
- Start with how it works today, then what changes after this PR.
- Frame the change as the question the system now asks and what happens for each answer (yes / no / inactive), including the important edge cases.
- Use product/runtime terms, not code symbols or implementation mechanics.
- Keep it short: a "today" paragraph plus one or two "after this PR" paragraphs.

### What changed

- Group by reviewer concern, not by file path.
- Use `###` subsections with domain names such as "Background job scheduling", "Live updates over websockets", or "Stable deep-link handling".
- Put the mental model first, then bullets for concrete behavior.
- Include important data model, runtime, API, UI, or dependency changes when they matter.

### Rollout / risk notes

- Include the 2-5 most useful things to watch after merge.
- Phrase risks as operational/product concerns, not vague fear.
- Explain why the risk is bounded or how the system recovers.

### Not in this PR

- Call out explicit deferrals so reviewers do not block on known follow-up work.
- Include adjacent tempting cleanup, polish, richer UX, or broader architecture work that was intentionally avoided.

### Test coverage / validation

- Separate coverage added from commands run.
- Include exact commands.
- Be honest about warnings, unrelated failures, or checks not run.
- Do not claim CI/local checks are green unless they are.

## Screenshot handling

Prefer GitHub user attachments over raw links when embedding screenshots.

If the `gh image` extension is installed, use it:

```bash
gh image --repo OWNER/REPO /path/to/screenshot.png
```

Then embed the returned `https://github.com/user-attachments/assets/...` URL:

```markdown
![Descriptive alt text](https://github.com/user-attachments/assets/<id>)
```

If `gh pr edit` fails with a Projects GraphQL deprecation error, update the PR body through the REST API instead:

```bash
gh api repos/OWNER/REPO/pulls/PR_NUMBER -X PATCH -F body="$(cat /tmp/pr-body.md)"
```

## Style notes

### Banned openers and words

The `writing-technical-prose` skill's banned register applies to every section. These PR-specific bans come on top of it:

- Never write "slice" (or "workstream", "vertical", "piece of the puzzle") to describe a PR. Say what the PR adds or changes.
- Never open the Summary with "This is the X of Y". Lead with the change: "Long chat sessions now compact their context mid-turn" beats "This is the compaction slice of the chat workstream".
- No "the guiding tradeoff" / "the key decision" framing. State the tradeoff directly: "Bounded initial payloads, at the cost of a second fetch on scrollback."
- No "shape" as a design noun ("the runtime shape", "the shape is coherent"). Name the behavior or the components.

### General

- Prefer concrete bullets over vague summaries.
- Keep reviewer-facing details high signal: behavior, contracts, risks, validation.
- Avoid overexplaining obvious implementation mechanics.
- Do not paste a raw changelog unless the PR is tiny.
- Use code formatting for table names, commands, feature flags, route paths, and symbols.
