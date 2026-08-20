# PRs

Titles and descriptions. Evidence base: 50+ PR titles the user personally rewrote after an agent generated them.

## Titles

Titles follow commit-subject style: lowercase, short imperative verb phrase, no trailing period on a single statement.

- Name the central change and stop. Cut implementation detail, motivation, issue IDs, and exhaustive change lists — that belongs in the body. "GA chat index v3: drop allowlist, global kill-switch gate, taxonomize extraction anomalies" became "ga agent index". "Sanitize auctor:// links copied from chat (AUC-6451)" became "sanitize uris copied from chat".
- Plain outcomes over promotional wording: "add syntax highlighting", "remove deck print", "harden file edit prefill", "update agent index dashboard".
- Backticks for exact identifiers — gates, fields, config keys: "deprecate `outlook_write_tools`", "move compaction `target_tokens` to statsig".
- Conventional prefixes like `fix(deck):` only for focused fixes where the component adds context. Drop mechanical prefixes otherwise ("fix(serde): ..." was rewritten without keeping the habit).
- A multi-outcome PR may keep a compound title, joined with a colon list or two short sentences: "harden hitl approvals: atomic answers, reject on invalid state, clean stale-client reload", "page on chat writer exceptions again. silence pinned-model overloaded."
- Product/system language over agent jargon: "use idiomatic mcp tool result", "correlate user turns with runtime state and model usage".
- If the title reads like a summary of everything the PR touches, shrink it until only the central change remains.

## Descriptions

Narrative, reviewer-friendly template: concise summary first, then structured detail. Explain what changed, why the changes belong together in one PR, what reviewers should watch, what is intentionally out of scope, and how the change was validated.

## Scope

- One PR unless the user asks for a stack. Do not split work into stacked PRs on your own initiative.
- Multi-change PRs: lay the changes out as a bulleted list grouped by reviewer concern.
- When a diagram explains the design better than prose, put it near the top of the description.
- For convention or format changes, show a before/after example or diff at a glance.

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

### <Area 2>

<Short paragraph explaining the area.>

- <specific behavior / codepath / UX change>

## Rollout / risk notes

Main risk areas to watch during dogfooding:

1. **<Risk area>**
   - <What could go wrong, why it is bounded, and what to watch.>

## Not in this PR

Explicitly deferred:

- <non-goal / follow-up>

## Test coverage / validation

Adds focused coverage for:

- <test / behavior area>

Recent local validation:

- `<command>`

Notes:

- <known warning, failing unrelated check, or CI/source-of-truth caveat>
```

## Section guidance

### Summary

- Open with what the PR does: "<Subject> now <behavior>". Describe the change itself, never its position in a plan or taxonomy.
- Name the branch's scope and the important tradeoff.
- Mention stacking, rollout path, or dogfooding status when relevant.

### ELI5

- Write for a non-expert: behavior before, then behavior after.
- Frame the change as the question the system now asks and what happens for each answer, including the important edge cases.
- Product/runtime terms, not code symbols. Keep it short.

### What changed

- Group by reviewer concern, not by file path.
- Use `###` subsections with domain names such as "Background job scheduling" or "Stable deep-link handling".
- Mental model first, then bullets for concrete behavior.

### Rollout / risk notes

- The 2-5 most useful things to watch after merge.
- Operational/product concerns, not vague fear. Explain why the risk is bounded or how the system recovers.

### Not in this PR

- Explicit deferrals so reviewers do not block on known follow-up work, including tempting adjacent cleanup that was intentionally avoided.

### Test coverage / validation

- Separate coverage added from commands run. Include exact commands.
- Be honest about warnings, unrelated failures, or checks not run. Never claim green unless it is.

## Screenshot handling

Prefer GitHub user attachments over raw links. If the `gh image` extension is installed:

```bash
gh image --repo OWNER/REPO /path/to/screenshot.png
```

Embed the returned `https://github.com/user-attachments/assets/...` URL:

```markdown
![Descriptive alt text](https://github.com/user-attachments/assets/<id>)
```

If `gh pr edit` fails with a Projects GraphQL deprecation error, update the body through the REST API:

```bash
gh api repos/OWNER/REPO/pulls/PR_NUMBER -X PATCH -F body="$(cat /tmp/pr-body.md)"
```

## Style notes

The banned register in [writing.md](writing.md) applies to every section. PR-specific bans on top:

- Never call a PR a "slice", "workstream", or "vertical". Say what it adds or changes.
- Never open the Summary with "This is the X of Y". Lead with the change: "Long chat sessions now compact their context mid-turn."
- No "the guiding tradeoff" / "the key decision" framing. State the tradeoff directly.
- Prefer concrete bullets over vague summaries. Do not paste a raw changelog unless the PR is tiny.
- Use code formatting for table names, commands, feature flags, route paths, and symbols.
