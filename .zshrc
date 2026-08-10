export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

alias -g ...='../..'
alias l='ls -lah'

autoload -Uz colors && colors
autoload -Uz vcs_info

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
HIST_STAMPS="mm/dd/yyyy"
setopt INC_APPEND_HISTORY       # write to history file immediately, not on shell exit
setopt EXTENDED_HISTORY         # record timestamp of each command
setopt SHARE_HISTORY            # share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST   # expire duplicates first when trimming history
setopt HIST_IGNORE_DUPS         # don't record an entry that was just recorded
setopt HIST_IGNORE_ALL_DUPS     # delete old entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS        # don't display previously found lines when searching
setopt HIST_IGNORE_SPACE        # don't record entries starting with a space
setopt HIST_SAVE_NO_DUPS        # don't write duplicate entries to the history file

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

# ── work units: one tmux session per unit of work, one ghostty tab attached to each ──
# wu <name>  attach-or-create session <name> rooted in cwd
# wu         dashboard: 🔔 bell (needs you) · ● activity since last viewed
wu() {
  [[ -z "$1" ]] && { wuls; return }
  tmux new-session -A -s "$1" -c "$PWD"
}
wuls() {
  tmux list-windows -a -F '#{?window_bell_flag,🔔,#{?window_activity_flag,●,·}} #{session_name}:#{window_index} #{window_name} — #{pane_current_command} @ #{pane_current_path}' 2>/dev/null \
    || echo "no tmux sessions"
}
wuk() { tmux kill-session -t "$1" }
_wu() { compadd ${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"} }
compdef _wu wu wuk

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
