---
name: writing-commits
description: Writes commit messages in the user's preferred style. Use whenever creating, amending, rebasing, or otherwise editing git commits.
---

# Writing Commits

Use the user's compact commit style for every commit you create or edit.

## Style

- Write commit subjects in all lowercase.
- Prefer short imperative subjects without a trailing period.
- Use plain language over conventional-commit prefixes unless the user asks for them.
- Keep bodies lowercase too when a body is needed.
- Do not add `Co-authored-by` trailers for Amp.
- Do not add Amp metadata trailers, including `Amp-Thread-ID`, unless the user explicitly asks for them.

## Before committing or amending

- Check the staged diff and choose the smallest accurate subject.
- If amending or rebasing existing commits, preserve the intended change while rewriting the message into this style.
- If there are multiple related commits, keep each subject specific enough to distinguish the change.

## Examples

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
Amp-Thread-ID: https://ampcode.com/threads/...
```
