# Evidence sections for a PR description

These sections extend the `style` skill's PR template (`style/reference/pr.md`). Keep that template's order and register. Add or replace only what is below. Omit a section when it truly does not apply, never because it is inconvenient.

## ELI5 gets a visual

Keep the ELI5 prose (behavior before, behavior after). Below it, add one visual from [visuals.md](visuals.md): a timeline for ordering bugs, a decision tree for classification changes, a state ladder for "what do we hold at this moment". The reader should understand the bug from the picture and the fix from the diff marks.

````markdown
## ELI5

<behavior before, plain language>

<behavior after, as the question the system now asks and what happens per answer>

```
<timeline / decision tree / state ladder>
```
````

## What changed gets structure diffs

Under each `###` area, when the change is control flow or structure, add a call-stack, component-tree, or file-layout diff before the bullets. The bullets then explain the marked lines.

## Proof section

Insert after "What changed" and before "Rollout / risk notes".

```markdown
## Proof

<One paragraph: the scenario, how it was run, on what stack, how many times per variant, and how the build under test was confirmed (the bundle grep, version string, or SHA).>

### Live reproduction, base vs branch

| moment | base (`<base branch>`) | branch |
| --- | --- | --- |
| 1 <name> | <observation> | <observation> |
| 2 <name> | <observation> | <observation> |
| ... | | |

### Screenshots

<Two or three pairs. Same moment, base on the left or first, branch second. Alt text names the moment and the variant.>

| base, after reload | branch, after reload |
| --- | --- |
| ![base after reload](<url>) | ![branch after reload](<url>) |

### Wire / state captures

<Only when the bug is on the wire or in stored state. The jq extract, the DB row, the log line. Verbatim, trimmed to what matters.>

### Reproduce it yourself

<The script path or the numbered commands. A reviewer with the stack running should get the same table.>
```

## Mechanical vs judgment (when the diff is mostly a move)

Insert after "What changed" when the PR is a refactor, rename, or extraction and the claim is "almost nothing changed".

```markdown
## Mechanical vs judgment

| Change | Files | Evidence |
| --- | --- | --- |
| Rename `HtmlPreviewViewer` → `HtmlViewer` | 4 | `diff <(sed 's/HtmlPreviewViewer/HtmlViewer/g' <(git show dev:<path>)) <path>` is empty |
| Extract `ImageViewer` | 1 | 29/29 non-import lines grep verbatim in `git show dev:<monolith>` |
| ... | | |

Where judgment was applied:

1. `<file>`: <what changed and why it was not mechanical>
2. ...
```

Every row's evidence is a command the reviewer can paste. The numbered list is exhaustive. If you are not sure a spot is mechanical, it goes in the list.

## Test coverage / validation, base vs branch

Replace the "Recent local validation" bullets with counts on both sides.

```markdown
## Test coverage / validation

Adds focused coverage for:

- <behavior>

Red on base, green on branch:

- `<test command>` on branch: 47/47 pass
- Same file with only `<changed files>` swapped to `<base>`: 44 pass, 3 fail, all in `<describe block>`

Regression sweep:

- `<suite command>` branch 1524 pass / base 1520 pass. Delta is the 4 new tests.
- `<other suite>` identical 4 failing files on both sides: `<names>`. Pre-existing.
- `pnpm check` exit 0.

## Limits

- <Layer not exercised>: <why>. Covered instead by <test / capture>.
- <Simulated step>: <what was simulated, with what exact message format, and what remained real>.
```

## Screenshot hosting

Prefer GitHub user attachments (`gh image --repo OWNER/REPO <png>`) so images survive if the Amp artifact host changes. When `gh image` is not installed, use `public_artifact_url` and say in the PR that the images are Amp-hosted. Never leave a local path in the body.

## Updating the body

Write the body to a file first (`/tmp/pr-body.md`), show the user the diff of the sections you changed, and edit only after they ask. When editing, replace stale validation blocks rather than appending below them. A PR body with two "validation" sections that disagree is worse than one.

```bash
gh api repos/OWNER/REPO/pulls/NUMBER -X PATCH -F body="$(cat /tmp/pr-body.md)"
```
