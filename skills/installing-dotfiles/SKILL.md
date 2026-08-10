---
name: installing-dotfiles
description: Installs tjbai's personal dotfiles (zsh config, git/tmux aliases, prompt, shell functions) onto the current machine, especially fresh Amp orbs. Use when asked to install my dotfiles, set up my shell, load my aliases, or make an orb feel like my laptop.
---

# Installing Dotfiles

Installs the bundled zsh configuration so the machine has the user's aliases and shell functions (`gs`, `gd`, `gco`, `gri`, `lsp`, `klsp`, `wu`, `gaws`, ...).

## Install

Run the bundled installer from this skill's base directory:

```bash
bash "$SKILL_DIR/scripts/install.sh"
```

Replace `$SKILL_DIR` with this skill's base directory as a plain filesystem path: strip the `file://` scheme and percent-decode the displayed base URI (`%40` → `@`, `%20` → space).

The installer:

1. Backs up any existing `~/.zshrc` to `~/.zshrc.pre-dotfiles`.
2. Copies the bundled `dotfiles/zshrc` to `~/.zshrc`.
3. Installs `zsh` via apt if missing (Debian orbs; uses sudo).
4. Generates `~/.zoxide.zsh` when zoxide is installed, otherwise stubs it so sourcing never fails. Stubs `~/.wd/wd.plugin.zsh` the same way.

## Using the aliases afterward

The Amp agent's shell is non-interactive bash, so aliases do not apply to plain `shell_command` invocations. When the user asks to run one of their aliases or functions, run it through interactive zsh:

```bash
zsh -ic 'gs'
```

The `running-zsh-aliases` skill covers this pattern in detail.
