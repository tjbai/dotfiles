# Commits

## Subjects

- All lowercase, short imperative, no trailing period.
- Plain language over conventional-commit prefixes unless the user asks for them.
- Keep bodies lowercase too when a body is needed.
- No `Co-authored-by` trailers for Amp. No Amp metadata trailers (`Amp-Thread-ID`) unless explicitly requested.
- Specific enough to distinguish neighboring commits. Never "wip", "checkpoint", "fixes", "address review".

Good:

```text
add deploy in ci
configure correct instance member role
bump sandbox bootstrap pin
fix stream redis typing for ci
```

Bad:

```text
Fix PR Checks and Review Issues
Make Cache Resolution Best Effort
Co-authored-by: Amp <amp@ampcode.com>
```

## History

- One intent per commit. Code, its tests, and its docs travel together.
- Before pushing, rewrite freely: amend or fixup follow-up changes into the commit that owns them instead of stacking correction commits.
- History should read as a deliberate sequence, not frenetic checkpointing.
- For a messy branch, propose a clean linear rewrite before merge instead of merging the mess.

## Before committing or amending

- Check the staged diff and choose the smallest accurate subject.
- The staged diff must satisfy the diff rules in [coding.md](coding.md): no format churn, no no-op hunks.
- When amending or rebasing, preserve the intended change while rewriting the message into this style.
