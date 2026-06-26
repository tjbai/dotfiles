---
name: removing-python-slop
description: Removes Python slop: over-defensive code, redundant parsing, unnecessary helpers, logger/error ceremony, and style cruft. Use when cleaning code that feels defensive, complex, abstracted, verbose, or distrustful of owned contracts.
---

# Removing Python Slop

Cut defensive ceremony until the code says what the system actually does.

Use this when code has grown around fear: broad try/catch blocks, shape checks for data we own, fallback parsers for unsupported formats, tiny one-use helpers, extra abstractions, verbose names, repeated comments, over-separated formatting, or logging that does not change recovery.

## Core stance

- Trust contracts this repo owns.
- Let unexpected exceptions propagate.
- Keep failure handling where it changes product behavior.
- Prefer one clear flow over many tiny helpers.
- Prefer direct calls over wrappers that only rename a call.
- Keep comments rare and load-bearing.
- Use short, concrete names.
- Use compact formatting when the code is simple.

This mirrors a tight house style: few comments, short names, few functions, colocate things that work together, less whitespace, less code. Compact multi-imports are fine. Trust the types. No logger ceremony.

## Cleanup workflow

1. Identify the owned boundary.
   - Find who writes the data, validates it, and calls this code.
   - If a TypeScript schema, pydantic model, database constraint, migration, or typed caller owns the shape, do not re-validate that shape here.
   - Keep checks only for true runtime boundaries: user input before validation, third-party responses, env vars, secrets, filesystem, network, and database availability.

2. Delete defensive branches that hide bugs.
   - Remove broad `except Exception`, `except OSError`, `except APIError`, or silent `return None` paths unless skipping is explicitly correct product behavior.
   - Let unexpected failures fail closed for security-sensitive work.
   - Keep narrow error handling when it maps a known external condition to a deliberate behavior.

3. Collapse unsupported compatibility paths.
   - If the writer emits base64, do not parse hex and raw utf-8 too.
   - If v1 policy supports exact hosts, do not prebuild wildcard/future routing branches.
   - If only one deployment path is supported, do not add three speculative env conventions.
   - Future extensibility is not a reason to ship extra branches now.

4. Inline one-use helpers.
   - Inline helpers that only wrap one method call, one env read, one simple transform, or one callsite-only branch.
   - Keep helpers when they name a real domain operation, centralize a fragile invariant, or are reused enough to reduce noise.
   - If helpers remain, place them near the flow that uses them.

5. Remove shape paranoia.
   - Stop doing `isinstance` checks inside code reached only after schema validation.
   - Stop using `.get(..., [])` for required fields in typed/persisted records.
   - Prefer `policy['rules']` when `policySchema` requires `rules`.
   - Keep top-level guards only where data crosses a weakly typed boundary and the caller can recover meaningfully.

6. Simplify error and logging ceremony.
   - Remove logs that just repeat the exception before re-raising.
   - Remove custom error classes unless callers distinguish them.
   - Keep domain errors when they produce user-facing behavior, fail closed, or preserve a security invariant.
   - Avoid redaction wrappers unless secrets could actually cross the boundary.

7. Tighten names and comments.
   - Prefer `bootstrap`, `policy`, `record`, `key` over long defensive names when local context is clear.
   - Delete comments that restate code.
   - Keep comments for weird runtime constraints, security invariants, replay/policy hazards, or model-facing contracts.
   - Move surviving comments to the code they explain. Avoid module docstrings or section banners for local plumbing.
   - Follow local style. In this style, comments are short lowercase `#` comments. Reserve loud notes for rare high-stakes caveats.

8. Tighten formatting.
   - Remove top-level narrative docstrings unless they are the API documentation surface.
   - Compact stdlib imports when local style allows it: `import os, re, base64, hashlib`.
   - Do not leave two blank lines between every tiny helper by reflex. Dense helper clusters are easier to scan when they are short.
   - Use blank lines inside longer functions to separate real phases: read config, decrypt secrets, call external service, build return value.
   - One-line guard returns are fine when they reduce ceremony: `if not result.data: return None`.
   - Avoid extracting a phase just to create a heading. If the phase is local and linear, keep it local and add whitespace only where it helps.

9. Re-run focused checks.
   - Run the narrow formatter/linter/test target for touched files.
   - Add or adjust a regression test only when the cleanup changes a meaningful behavior or removes a previous fallback.

## What to keep

Keep code that protects a real boundary:

- required env vars
- secret decryption failures
- third-party response validation where the API can lie
- database/network failures that must fail closed
- authorization and tenant boundaries
- redaction when caller-provided secrets may enter errors or logs
- idempotency or retry semantics
- migration/backfill compatibility that is still live

## What to remove

Usually remove:

- catch-and-ignore blocks that make production look healthy while silently disabling a feature
- multiple parsing formats when the writer emits exactly one format
- `dict.get` defaults for required fields owned by a schema
- local wrappers around one env var or one method call
- speculative branches for future providers, versions, or protocols
- comments explaining what the next line already says
- module docstrings that narrate implementation details better shown by the function flow
- decorative blank lines between small adjacent helpers
- duplicate client-side and server-side validation after persistence, unless it protects against data drift with a clear recovery path

## Formatting preferences

For Bai's code, compact is usually better than ceremonially formatted.

Prefer this shape for local plumbing modules:

```python
import os, re, base64, hashlib
from dataclasses import dataclass

import httpx

CONSTANT = 'value'

@dataclass(frozen=True)
class Bootstrap:
    env: dict[str, str]

class HydrationError(RuntimeError):
    pass

def _required_env(name: str) -> str:
    value = os.getenv(name, '').strip()
    if not value:
        raise HydrationError(f'missing {name}')
    return value

def _local_transform(value: str) -> str:
    return re.sub(r'[^A-Z0-9_]', '_', value.upper())
```

Avoid this shape unless the file's formatter or local style requires it:

```python
"""long prose about plumbing that repeats the function body"""

import os
import re
import base64
import hashlib


CONSTANT = 'value'


@dataclass(frozen=True)
class Bootstrap:
    env: dict[str, str]


def _local_transform(value: str) -> str:
    return re.sub(r'[^A-Z0-9_]', '_', value.upper())
```

Use more vertical space inside a long function when it marks a real step. Do not use vertical space to make every assignment look important.

## Example pattern

Before:

```python
def _active_key() -> bytes:
    raw = _required_env('CREDENTIAL_ENCRYPTION_KEY')
    try:
        decoded = base64.b64decode(raw)
    except Exception:
        decoded = b''
    candidates = [decoded, bytes.fromhex(raw) if re.fullmatch(r'[0-9a-fA-F]{64}', raw) else b'', raw.encode()]
    for candidate in candidates:
        if len(candidate) == 32:
            return candidate
    raise RuntimeError('invalid key')
```

After, when the writer owns base64:

```python
key = base64.b64decode(_required_env('CREDENTIAL_ENCRYPTION_KEY'), validate=True)
if len(key) != 32:
    raise RuntimeError('invalid key')
```

The second version is not less safe. It is more honest. Unsupported encodings fail instead of becoming a hidden contract.

## Review checklist

Ask these questions before finishing:

- what contract owns this shape?
- what failures are expected product states?
- what failures should be loud?
- what helpers survived, and why?
- did any fallback become an accidental public contract?
- did the cleanup reduce code paths without reducing real safety?
- did formatting get tighter, or did it keep ceremonial spacing/docstrings?
- did focused checks cover the touched behavior?
