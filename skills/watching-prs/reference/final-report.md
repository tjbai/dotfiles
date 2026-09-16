# Final report

Use this format and omit empty optional sections:

```text
PR: <url>
Result: ready | externally blocked | escalated | watch timed out | merged | closed
Head: <short OID>, stable across final query
Base: <branch> at <short OID>

Changed:
- <code, conflict, review reply, resolution, restack, or rerun>

Evidence:
- <command or check>: <result>

Reviews: <zero actionable threads, or exact unresolved decision>
CI: <zero PR-caused failures, or class + check link + owner>
Merge: <mergeable state, or blocker>
Worktree: clean

Stack:
- <PR URL>: <head OID>, <result>

Stop reason: <rule that ended this pass>
```

For `status`, replace `Changed` with `Observed`. For `watch`, report state changes as they happen and send this report once at the stop point.

Do not hide pending checks, unrelated persistent failures, lease failures, or approval gates under a ready result.
