# CI classification

Classify checks for the current PR head only. Record the head OID with each result.

## Decision order

1. **PR-caused**: The failure reproduces on the PR head and points to changed code, changed tests, or a conflict repair.
2. **base-branch**: The same check fails on the current base with the PR change absent.
3. **flaky**: The repository records the failure as intermittent, or the same unchanged job passes on one bounded rerun.
4. **infrastructure**: The job did not test the change because a runner, network, service, quota, or platform failed.
5. **approval-gated**: GitHub, an environment, or a human must approve the job before it can run.

Do not infer a class from a red icon. Read the job summary and failing logs. Compare the base run when the cause can be shared.

## Actions

| Class | Action |
| --- | --- |
| `PR-caused` | Fix, test, and include the result in the next batch push. |
| `base-branch` | Do not change the PR. Link the matching base failure and report its owner. |
| `flaky` | Rerun the failed job once. Stop if it fails again without PR evidence. |
| `infrastructure` | Do not change product code. Report the failed service or runner and its owner. |
| `approval-gated` | Do not bypass the gate. Report the required approval and stop. |

Pending checks are not failures. They prevent a merge-ready claim until they finish or become a named external blocker.

Use `gh pr checks "$PR" --json name,state,bucket,workflow,link,startedAt,completedAt` for the summary. Follow each failed check link or inspect its workflow run with `gh run view`.

Before a rerun, confirm the workflow run belongs to the current head. Prefer a failed-job rerun:

```bash
gh run rerun "$RUN_ID" --failed
```
