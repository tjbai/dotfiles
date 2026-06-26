---
name: running-zsh-aliases
description: Runs user-mentioned zsh aliases, shell functions, and interactive zsh commands correctly from Amp's default bash shell. Use when the user mentions aliases or commands such as a custom lint or run alias that exist only in zsh interactive mode.
---

# Running zsh aliases

Use this when the user mentions a command that is likely a zsh alias, zsh function, or shell setup loaded only in interactive zsh.

Amp runs shell commands through bash by default. Do not run zsh-only aliases directly in bash.

Run them through interactive zsh:

```bash
zsh -ic 'mycheck'
zsh -ic 'myrun'
zsh -ic 'alias_name arg1 arg2'
```

On Apple Silicon, if a zsh-loaded command fails because Python or a native extension is running under the wrong architecture, avoid `/usr/local/bin/zsh`. It may be x86_64-only. Use the system zsh explicitly under arm64/arm64e:

```bash
arch -arm64e /bin/zsh -ic 'mycheck --fix'
arch -arm64 /bin/zsh -ic 'mycheck --fix'
```

Rules:

- Use `zsh -ic '<command>'` for user aliases, zsh functions, and commands defined by interactive zsh startup files.
- Use `arch -arm64e /bin/zsh -ic '<command>'` when PATH zsh is `/usr/local/bin/zsh` or appears x86_64-only and the command needs arm64 Python/native extensions.
- Quote the command as one shell string so zsh receives it intact.
- Keep using the normal shell for ordinary commands that are not aliases or zsh-only functions.
- If the command contains single quotes, use safe shell quoting before passing it to `zsh -ic`.
