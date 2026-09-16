---
name: watching-prs
description: Converges pull requests and stacked pull requests through review, conflicts, checks, and bounded monitoring. Use for converge, converge-stack, watch, or status requests for GitHub PRs.
compatibility: Requires git, gh, jq, repository push access for converge modes, and an authenticated GitHub CLI session.
argument-hint: "converge <PR> | converge-stack <PRs> | watch <PR> --for <duration> | status <PR>"
---

# Watching PRs

Move a GitHub pull request to a stable merge-ready or externally blocked state. Keep every loop bounded.

## Modes

- A PR without a mode: Use `converge`.
- `converge <PR>`: Run one complete convergence pass. Allow no more than two repair cycles, then stop.
- `converge-stack <PRs>`: Order the given PRs from base to tip. Converge each PR and restack changed descendants.
- `watch <PR> --for <duration>`: Monitor only until a stop rule applies. Do not edit, reply, resolve, push, or rerun checks.
- `status <PR>`: Query once and report the current state. Do not change local or remote state.

Treat a converge request as approval to update the named PR branches. Do not push other branches or change repository settings.

## Limits

- A **repair cycle** can change code, review-thread state, or CI state. Batch its code changes into one push per branch.
- Run no more than two repair cycles in one convergence pass.
- Rerun a known flaky check no more than once per convergence pass.
- For `watch`, derive a deadline from `--for`. Set a fixed query budget before the first query.
- Space watch queries based on the given duration and the expected check time. Never poll without both bounds.
- Stop a watch on merge, close, completion, deadline, or exhausted query budget.
- Report only state changes, blockers, and completion during a watch.

## 1. Establish the state

1. Confirm `gh auth status` for the PR host.
2. Resolve each PR to its URL, repository, number, state, base, head, head OID, and fork owner.
3. Fetch the base and each head from its exact remote. Record every remote head OID as a force-push lease.
4. Inspect `git status`, active worktrees, remotes, upstreams, and branch containment.
5. Use a clean existing worktree for the head, or create a dedicated worktree. Never overwrite another worktree or uncommitted changes.
6. For stacks, prove the parent of each PR from the base and head refs. Read [stacked PRs](reference/stacked-prs.md).
7. Stop if the stack order, head repository, branch owner, or push target is uncertain.

Capture one baseline snapshot:

```bash
gh pr view "$PR" --json url,number,state,isDraft,baseRefName,baseRefOid,headRefName,headRefOid,headRepositoryOwner,headRepository,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup
bash "$SKILL_DIR/scripts/review-threads.sh" "$PR" > review-threads.json
gh pr checks "$PR" --json name,state,bucket,workflow,link,startedAt,completedAt
```

Replace `$SKILL_DIR` with this skill's filesystem path.

## 2. Repair topology and conflicts

1. Compare the recorded base OID with the fetched base.
2. Rebase the PR head onto its intended base when the branch is behind or conflicted.
3. Inspect each conflict against the PR intent, tests, and both branch versions.
4. Resolve only conflicts that preserve clear behavior.
5. Stop on a behavior-changing conflict with more than one valid result.
6. Run targeted checks before any push.
7. Push with the recorded lease, not plain `--force`.

```bash
git push --force-with-lease="refs/heads/$HEAD_REF:$RECORDED_HEAD_OID" "$HEAD_REMOTE" "HEAD:refs/heads/$HEAD_REF"
```

After a changed stack head, restack every descendant in order. Update each lease only after a successful fetch or push.

## 3. Process every review thread

Use `scripts/review-threads.sh` because `gh pr view --comments` does not return all review threads. The script paginates threads and their comments.

Classify every review comment before acting. Use replies as context when they do not state a new finding.

| Class | Required action |
| --- | --- |
| `valid` | Fix it, run evidence, reply with the evidence, then resolve the thread. |
| `already-fixed-or-outdated` | Cite the current head or code location, reply, then resolve the thread. |
| `incorrect-or-non-salient` | Explain why it does not apply, reply with evidence, then resolve the thread. |
| `ambiguous-product-decision` | Do not guess or resolve. Report the exact decision and available options. |

Do not silently resolve a non-actionable comment. Do not treat a bot summary, review status, or prior reply as a new finding.

Reply before resolution:

```bash
gh api graphql -f query='mutation($thread:ID!,$body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$thread,body:$body}){comment{id url}}}' -F thread="$THREAD_ID" -f body="$REPLY"
gh api graphql -f query='mutation($thread:ID!){resolvePullRequestReviewThread(input:{threadId:$thread}){thread{id isResolved}}}' -F thread="$THREAD_ID"
```

Make replies short. Name the fix or reason, the current head, and the check that supports the result.

## 4. Verify and push

1. Run the smallest checks that cover each changed behavior and conflict.
2. Add broader checks only when shared code or repository guidance requires them.
3. Review the full diff and worktree state.
4. Fold repair commits into the commit that owns the change when history policy permits it.
5. Batch all code repairs for one cycle into one push per branch.
6. Re-fetch the remote head after the push. Stop if it differs from the pushed OID.

Do not push from `status` or `watch`.

## 5. Classify current-head CI

Inspect checks only after confirming the PR still points to the expected head OID. Read [CI classification](reference/ci-classification.md).

Use exactly one class for each failed or blocked check:

- `PR-caused`
- `base-branch`
- `flaky`
- `infrastructure`
- `approval-gated`

Fix only `PR-caused` failures. Rerun a known flake once. Report all other classes with evidence and their owner.

## 6. Re-query to stability

After each repair cycle:

1. Re-fetch the head and confirm its OID.
2. Paginate review threads again.
3. Query mergeability and checks for that OID.
4. Start the second repair cycle only for new actionable review findings or PR-caused failures.
5. Stop and escalate if a third repair cycle would be required.

For the final query, capture the head OID before and after all other queries. Repeat the state query if the OID changed.

Completion requires all of these conditions:

- Zero unresolved actionable review threads.
- Zero PR-caused CI failures.
- The PR is mergeable, or an external blocker has a clear class and owner.
- The worktree is clean.
- The remote head is stable across the final query.

Stop early on merge, close, product judgment, conflict ambiguity, uncertain stack topology, persistent unrelated failures, or a human approval gate.

## 7. Report

Use [the final report](reference/final-report.md). Include current OIDs and links for blockers. Do not say a PR is ready when checks are pending without naming that external state.
