export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

alias -g ...='../..'
alias l='ls -lah'

autoload -Uz colors && colors
autoload -Uz vcs_info

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="mm/dd/yyyy"
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
fpath=(~/.wd $fpath)
autoload -Uz compinit

compinit -C -u

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%F{green}%b%f'
zstyle ':vcs_info:git:*' actionformats '%F{green}%b%f (%F{red}%a%f)'
precmd() { vcs_info }
setopt PROMPT_SUBST

PROMPT='%F{magenta}%n@%m%f %F{blue}%~%f$ '
RPROMPT='%(?..%F{red}%? ↵%f) ${vcs_info_msg_0_}'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.docker/bin"
export PATH="$PATH:$HOME/Library/Python/3.12/bin"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export EDITOR='vim'

nv() {
  if [ $# -eq 0 ]; then
    nohup neovide . </dev/null &>/dev/null &
  else
    nohup neovide "$@" </dev/null &>/dev/null &
  fi
  disown %%
}
alias lear="clear" # common typo lol
alias gst="git status"
alias gs="git status"
alias ga="git add"
alias grs="git restore"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gcb="git checkout -b"
alias grh="git reset"
gri() {
  local n="$1"
  if [[ -z "$n" || ! "$n" =~ '^[0-9]+$' ]]; then
    echo "Usage: gri <n> [rebase args...]" >&2
    return 2
  fi
  shift
  git rebase -i "$@" "HEAD~$n"
}
alias py="python3"
alias python="python3"
alias uvpy="uv run python"
alias ts="date +%Y%m%d%H%M%S"
alias lsmd="ls -d *.md 2>/dev/null"
alias npm="pnpm"
alias ghpr="gh pr create --base"
alias tsc="npx tsc --noEmit -p tsconfig.json"
alias codexh="codex --model=gpt-5-codex -c model_reasoning_effort=\"high\""
alias test="uvpy -m pytest"

lsp() { lsof -i :$1 }
klsp() { lsof -i :$1 | awk 'NR>1 {print $2}' | xargs -r kill -9 }
gaws() { git diff -U0 -w --no-color "$@" | git apply --cached --ignore-whitespace --unidiff-zero - }

bindkey '\ew' backward-kill-line
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

source ~/.zoxide.zsh
source ~/.wd/wd.plugin.zsh

[[ -f ".aliases" ]] && source ".aliases"

# Coursier disabled; `cs` is Claude Squad.
path=("${(@)path:#/Users/bai/Library/Application Support/Coursier/bin}")

# private, identity/work-specific config (not committed in plaintext)
[[ -f ~/.zshrc.private ]] && source ~/.zshrc.private
