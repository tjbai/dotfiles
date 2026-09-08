---
name: proving-changes
description: "Produces concrete, reviewer-checkable evidence that a change works and introduces no regression: a live example in a real stack, before/after runs of the same scenario driven through the browser with screenshots and captures, red-on-base/green-on-branch tests, an honest limits list, and a PR description that shows the proof with compact visuals. Use when asked to prove, show, demonstrate, verify, produce evidence, or give irrefutable/definitive proof that a fix or PR works. Triggers on: prove it, show me it works, concrete evidence, irrefutable proof, definitive proof, live example, before/after, no regression."
---

# Proving changes

The reviewer should never have to trust you. Every claim ships with something they can look at or re-run: a screenshot at a named moment, a pasted command with its output, a script that reproduces the scenario, a table with counts. "Tests pass" and "verified in the browser" are not evidence. They are claims.

Read [reference/visuals.md](reference/visuals.md) before writing the report. Read [reference/pr-evidence.md](reference/pr-evidence.md) before writing the PR description.

## Workflow

1. **Turn the claim into an observable question.** Before running anything, write down: the scenario, the exact observation that means "works", and the exact observation that means "broken". If you cannot name what failure looks like, you do not know what you are proving yet.
2. **Build a live example.** Use the real stack (local dev, orb preview, staging), the real data path, and a seeded scenario that hits the changed code. Fixtures and mocks prove the unit. Only the live path proves the feature.
3. **Run the same scenario before and after.** Base and branch go through the identical script. Confirm the build under test is the variant you think it is (grep the served bundle for a symbol only the branch has, check a version string, read the git SHA). A before/after where you cannot prove which build ran is worthless.
4. **Capture, do not describe.** Screenshots at named moments, DOM reads, network captures, DB rows, log lines, test counts. Verbatim commands and output excerpts. Then inspect each capture yourself with `view_media` and check it shows what you claim.
5. **Write the limits.** What layer did you not exercise, why, and what covers it instead. State it plainly. A proof with an honest gap beats a proof that hides one.
6. **Put the evidence in the deliverable.** The PR description by default, a report file when there is no PR. Chat is where you tell the user it is done, not where the evidence lives.

## The proof ladder

Pick rungs by the cost of being wrong. A one-line copy fix needs one rung. A fix for a race in production needs all of them. Each rung says what it covers and what it does not.

| Rung | What it proves | How |
| --- | --- | --- |
| Focused test, red on base, green on branch | The test detects the bug | Run the test on the branch. Swap only the changed source files to base (`git checkout <base> -- <files>`), rerun the same test, confirm the new tests fail and nothing else does. Restore and confirm `git status` is clean. |
| Regression sweep, base vs branch | No unrelated behavior changed | Run the suite on the branch and on base in a separate worktree (`git worktree add ../base-check <base>`). Every delta must be attributable to the PR. Pre-existing failures must be identical on both sides. |
| Code reading with `file:line` | The fix has no obvious hole | Answer the specific "can X happen" questions with line citations, not reassurance. |
| Live reproduction | The user-visible behavior is right | Seed the scenario, drive the browser, capture the moments, repeat for base and branch. |
| Boundary bracketing | The limits are where you say | Fixtures just under, at, and just over each threshold. Size them from real data (the p99 of production, not a guess). |

## The browser as an instrument

Use whatever browser tool is installed (`agent-browser` in orbs, Playwright locally). Treat it as a measuring device, not a demo.

- **Name the moments.** Decide the checkpoints before you start: `1-before`, `2-after-reload`, `3-after-reload-plus-10s`, `4-after-second-send`, `5-final`. Screenshot each. The same names on both variants so the reviewer can compare pairs.
- **Read state, not pixels, when a fact matters.** `eval` the DOM for the button that should exist, the alert that should not, the text length that should grow. Screenshots show. DOM reads prove.
- **Capture the wire when the bug is on the wire.** HAR or request logs. Extract the requests that matter with `jq` and keep the extract, not the whole file.
- **Hide developer overlays** (React Scan, Next dev badge, support widgets) before screenshotting. Product UI only.
- **Critique your own screenshots.** Open each with `view_media` and ask: does this show the claim? Is anything in frame that undermines it? Fix and recapture. Three passes is normal. Delegate the loop to a subagent when it is polish, not proof.
- **Repeat.** One run is an anecdote. Run each variant at least twice and say so.

## Evidence hygiene

- One directory per proof: `evidence/` or an artifacts folder. Inside: `scenario.sh` (or the exact command list), screenshots with the moment prefix, extracts (`*.json`, `*-log.txt`), `REPORT.md`.
- Delete noisy or superseded runs before you report. Keep only the runs you cite.
- Paste commands and output excerpts verbatim. Counts, failing test names, exit codes. Never paraphrase a result.
- When the claim is "this diff is mechanical", prove it with re-runnable commands: `git diff --name-status` for renames, `diff <(sed ...)` for renamed symbols, verbatim-line counts. Then list every place judgment was applied. The list of exceptions is the proof.

## Leave the human a way to check

A proof the user can only read is weaker than one they can click. When feasible, hand over one of:

- A running preview URL with the seeded scenario and a short rubric of cases to try.
- A single static HTML artifact they can open and click through (see `explain-like-im-chud` for the page style).
- A test plan with an empty evidence table (`case | result | evidence | tester | date`) for staging.

## Report outline

Whether it lands in a PR body, a `REPORT.md`, or a reply to a parent thread, the report has the same bones:

1. One paragraph: what was proved, how, verdict. `fixes the bug: yes/no`. `regressions found: none / list`.
2. Before/after table for the live scenario, one row per named moment, one column per variant.
3. Screenshots embedded in pairs (base, branch) for the two or three moments that matter most. Not all of them.
4. Test counts and exact commands, base vs branch.
5. Code-reading findings with `file:line`.
6. Limits: the unexercised layer and what stands in for it.

Use the visual shapes in [reference/visuals.md](reference/visuals.md) wherever a diagram replaces a paragraph: a timeline for a race, a decision tree for a classification, a call-stack diff for a control-flow change, a component-tree diff for UI.

## In a PR description

Follow the `style` skill's PR template (`reference/pr.md`). This skill adds to it, it does not replace it. See [reference/pr-evidence.md](reference/pr-evidence.md) for the sections and their templates. The short version:

- The ELI5 gets a visual. When the user says "I need a visual or something", it was already too late.
- Add a `## Proof` (or `## Live reproduction`) section with the before/after moment table and embedded screenshot pairs.
- Replace "Recent local validation" bullets with base-vs-branch counts and the red-on-base result.
- Add `## Limits` under validation. Never omit it to look cleaner.
- Screenshots go through `gh image` (GitHub user attachments) when available, else `public_artifact_url`. Say which.

## Do not

- Do not report a proof from memory of the run. Re-read the captures.
- Do not run only the happy path. The proof is in the moment where base breaks and branch does not.
- Do not call a pre-existing failure a regression, or a regression a pre-existing failure. Show it identical on both sides or own it.
- Do not push, comment, or edit the PR body until the user asks. Prepare the body in a file and offer.
- Do not fill the report with every screenshot. Pick the pairs that carry the claim and link the rest.
