# Stacked PRs

## Prove the order

1. Read every PR's repository, base ref, base OID, head ref, and head OID.
2. Build an edge from PR A to PR B only when B's base ref is A's head ref in the expected repository.
3. Confirm each edge with fetched commits. The parent head must be an ancestor of the child head before repair.
4. Require one base-to-tip order with no gaps, forks, cycles, or extra parent candidates.
5. Stop if branch names and commit ancestry disagree. Ask for the intended parent before rewriting a branch.

An open PR list can help find an omitted parent or child:

```bash
gh pr list --state open --limit 100 --json number,url,baseRefName,headRefName,headRefOid,headRepositoryOwner
```

## Restack

Record all remote head OIDs before the first rewrite. Then work from base to tip:

1. Converge the base PR.
2. Fetch its new remote head.
3. Rebase the direct child onto that exact OID.
4. Resolve only behavior-preserving conflicts.
5. Run checks for the child's changed range.
6. Push the child with `--force-with-lease` against its recorded remote OID.
7. Fetch and record the child's new OID before processing its child.

Use `git rebase --onto <new-parent> <old-parent> <child>` when the old parent is known. Do not rebase a descendant onto a branch name that can move during the operation.

If a lease fails, fetch and inspect the remote change. Never replace the new remote head without explicit confirmation.

After the tip push, re-query every PR. A descendant can gain conflicts, review changes, or new checks after its parent changes.
