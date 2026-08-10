#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$SKILL_DIR/dotfiles/zshrc"

if [[ ! -f "$SRC" ]]; then
  echo "bundled zshrc not found at $SRC" >&2
  exit 1
fi

if [[ -f "$HOME/.zshrc" && ! -f "$HOME/.zshrc.pre-dotfiles" ]]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.pre-dotfiles"
  echo "backed up existing ~/.zshrc to ~/.zshrc.pre-dotfiles"
fi

cp "$SRC" "$HOME/.zshrc"
echo "installed ~/.zshrc"

if ! command -v zsh >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y -qq zsh
    echo "installed zsh"
  else
    echo "zsh not found and apt-get unavailable; install zsh manually" >&2
  fi
fi

if command -v zoxide >/dev/null 2>&1; then
  zoxide init zsh > "$HOME/.zoxide.zsh"
  echo "generated ~/.zoxide.zsh"
elif [[ ! -f "$HOME/.zoxide.zsh" ]]; then
  : > "$HOME/.zoxide.zsh"
  echo "stubbed ~/.zoxide.zsh (zoxide not installed)"
fi

if [[ ! -f "$HOME/.wd/wd.plugin.zsh" ]]; then
  mkdir -p "$HOME/.wd"
  : > "$HOME/.wd/wd.plugin.zsh"
  echo "stubbed ~/.wd/wd.plugin.zsh"
fi

echo "done; verify with: zsh -ic 'alias | head'"
