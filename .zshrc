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
alias py="python3"
alias python="python3"
alias uvpy="uv run python"
alias ts="date +%Y%m%d%H%M%S"
alias npm="pnpm"
alias ghpr="gh pr create --base"
alias chat="uvpy scripts/run/chat.py"
alias tsc="npx tsc --noEmit -p tsconfig.json"
alias codexh="codex --model=gpt-5-codex -c model_reasoning_effort=\"high\""
alias claude="$HOME/.claude/local/claude"

alias fish="ssh tbai4@login.rockfish.jhu.edu -t 'bash --noprofile --norc -c \"source /etc/profile.d/modules.sh && module load zsh && zsh && source ~/.bashrc\"'"
alias perl="ssh perl -i ~/.ssh/nersc"
alias perlog="sshproxy -f"

lsp() { lsof -i :$1 }
klsp() { lsof -i :$1 | awk 'NR>1 {print $2}' | xargs -r kill -9 }
kall() { klsp 3000; klsp 3001; klsp 8000; klsp 1234; klsp 3333; klsp 6379 }
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

[[ -f ".aliases" ]] && source ".aliases"
