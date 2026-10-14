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
  local sock="${TMPDIR:-/tmp}/nv-neovide.sock"

  # branch name or PR URL: check out first, then open the resulting cwd
  if (( $# == 1 )) && [[ "$1" != -* && ! -e "$1" ]]; then
    if [[ "$1" == https://github.com/*/pull/* ]] ||
       git show-ref --verify --quiet "refs/heads/$1" 2>/dev/null ||
       git show-ref --verify --quiet "refs/remotes/origin/$1" 2>/dev/null; then
      gco "$1" || return
      set -- .
    fi
  fi

  # attach to a running nv-launched neovide if it's alive
  if [[ -S "$sock" ]] && nvim --server "$sock" --remote-expr 1 &>/dev/null; then
    local -a files
    local f
    for f in "${@:-.}"; do
      files+=("${f:a}")
    done
    nvim --server "$sock" --remote-tab "${files[@]}"
    nvim --server "$sock" --remote-expr "execute('tcd ' . fnameescape('${PWD//\'/''}'))" >/dev/null
    osascript -e 'tell application "Neovide" to activate' &>/dev/null
    return
  fi

  rm -f "$sock"
  nohup neovide "${@:-.}" -- --listen "$sock" </dev/null &>/dev/null &
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
gco() {
  if (( $# == 1 )) && [[ "$1" != -* ]]; then
    local target="$1"
    if [[ "$target" == https://github.com/*/pull/* ]]; then
      local branch
      branch="$(gh pr view "$target" --json headRefName --jq .headRefName 2>/dev/null)"
      if [[ -z "$branch" ]]; then
        echo "gco: could not resolve branch for $target" >&2
        return 1
      fi
      if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        gh pr checkout "$target"
        return
      fi
      target="$branch"
    fi
    local worktree current_worktree
    worktree="$(git for-each-ref --format='%(worktreepath)' "refs/heads/${target#refs/heads/}" 2>/dev/null)"
    current_worktree="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -n "$worktree" && "$worktree" != "$current_worktree" ]]; then
      cd -- "$worktree"
      return
    fi
    # no local branch: fetch it from origin so checkout can create a tracking branch
    if ! git show-ref --verify --quiet "refs/heads/$target" &&
       ! git rev-parse --verify --quiet "$target^{commit}" >/dev/null; then
      git fetch origin "refs/heads/${target}:refs/remotes/origin/${target}" 2>/dev/null
    fi
    git checkout "$target"
    return
  fi
  git checkout "$@"
}
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
alias ghm="gh pr merge --merge"
alias tsc="npx tsc --noEmit -p tsconfig.json"
alias codexh="codex --model=gpt-5-codex -c model_reasoning_effort=\"high\""
alias test="uvpy -m pytest"
alias atc="amp thread continue"

allnight() { # allnight [hours] [fish|wave] — stay awake; fish = asciiquarium, wave = kanagawa
  local a hours scene
  for a in "$@"; do case "$a" in fish|wave) scene=$a ;; *) hours=$a ;; esac; done
  local -a caf=(caffeinate -dis)
  [[ -n "$hours" ]] && caf+=(-t $(printf '%.0f' $(( hours * 3600 ))))
  if [[ -n "$scene" ]]; then
    "${caf[@]}" & local cafpid=$!
    case "$scene" in
      fish) asciiquarium ;;
      wave) ~/dev/dotfiles/bin/kanagawa ${hours:+--hours $hours} ;;
    esac
    kill $cafpid 2>/dev/null
  else
    "${caf[@]}"
  fi
}
lsp() { lsof -i :$1 }
klsp() { lsof -i :$1 | awk 'NR>1 {print $2}' | xargs -r kill -9 }
gaws() { git diff -U0 -w --no-color "$@" | git apply --cached --ignore-whitespace --unidiff-zero - }
ss() { git -C ~/auctor/scratch pull --rebase --autostash && git -C ~/auctor/scratch push }

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

# bun completions
[ -s "/Users/bai/.bun/_bun" ] && source "/Users/bai/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# land <pr-url|number> [timeout-minutes] — in the background: wait for CI, merge with ghm, say what happened
# land [status] | land clear | land cancel <number>
LAND_DIR=~/.local/state/land
land() {
  case "$1" in
    ""|status) _land_status; return ;;
    clear) _land_clear; return ;;
    cancel)
      [[ -f "$LAND_DIR/$2/pid" ]] || { echo "land: no job for #$2" >&2; return 1 }
      kill "$(<"$LAND_DIR/$2/pid")" 2>/dev/null
      _land_finish "$LAND_DIR/$2" cancelled "cancelled PR $2" 2>/dev/null
      return ;;
  esac
  local pr="$1" timeout="${2:-10}"
  [[ "$timeout" =~ '^[0-9]+$' ]] || { echo "usage: land <pr> [timeout-minutes]" >&2; return 2 }
  local number title
  IFS=$'\t' read -r number title < <(gh pr view "$pr" --json number,title --jq '[.number,.title]|@tsv' 2>/dev/null)
  [[ -z "$number" ]] && { echo "land: could not read PR $pr" >&2; return 1 }
  local dir="$LAND_DIR/$number"
  if [[ -f "$dir/pid" ]] && kill -0 "$(<"$dir/pid")" 2>/dev/null; then
    echo "land: #$number is already being watched" >&2; return 1
  fi
  rm -rf "$dir"; mkdir -p "$dir"
  print -r -- "$title" > "$dir/title"
  date +%s > "$dir/start"
  print -r -- $'watching\t'"starting" > "$dir/status"
  ( _land_watch "$pr" "$number" "$title" "$timeout" "$dir" ) > "$dir/log" 2>&1 &!
  print $! > "$dir/pid"
  echo "land: watching #$number for up to ${timeout}m: $title"
}
_land_watch() {
  local pr="$1" number="$2" title="$3" timeout="$4" dir="$5"
  local start=$SECONDS state mstatus draft checks
  while true; do
    IFS=$'\t' read -r state mstatus draft checks < <(
      gh pr view "$pr" --json state,mergeStateStatus,isDraft,statusCheckRollup --jq '
        . as $pr | ($pr.statusCheckRollup // []) as $c
        | (if ([$c[] | select((.status? // "COMPLETED") != "COMPLETED" or ((.state? // "") | IN("PENDING","EXPECTED")))] | length) > 0 then "pending"
           elif ([$c[] | select(((.conclusion? // .state? // "") | IN("FAILURE","CANCELLED","TIMED_OUT","ACTION_REQUIRED","ERROR","STARTUP_FAILURE")))] | length) > 0 then "failed"
           else "passed" end) as $checks
        | [$pr.state, $pr.mergeStateStatus, $pr.isDraft, $checks] | @tsv'
    )
    [[ -z "$state" ]] && { _land_finish "$dir" blocked "could not read PR $number, revisit"; return 1 }
    case "$state" in
      MERGED) _land_finish "$dir" merged "PR $number already merged: $title"; return 0 ;;
      CLOSED) _land_finish "$dir" blocked "PR $number is closed, not merging: $title"; return 1 ;;
    esac
    [[ "$draft" == true ]] && { _land_finish "$dir" blocked "PR $number is a draft, revisit: $title"; return 1 }
    case "$mstatus/$checks" in
      */pending|UNKNOWN/*) ;;
      BEHIND/*)
        echo "$(date +%H:%M) behind base, updating branch"
        gh pr update-branch "$pr" >/dev/null || { _land_finish "$dir" blocked "PR $number blocked, could not update branch, revisit: $title"; return 1 } ;;
      CLEAN/*|HAS_HOOKS/*|UNSTABLE/*)
        local note=""; [[ "$mstatus" == UNSTABLE ]] && note=", with a non-required check failing"
        if ghm "$pr"; then _land_finish "$dir" merged "merged PR $number$note: $title"; return 0
        else _land_finish "$dir" blocked "PR $number merge failed, revisit: $title"; return 1; fi ;;
      */failed) _land_finish "$dir" blocked "PR $number blocked, CI failed, revisit: $title"; return 1 ;;
      DIRTY/*)  _land_finish "$dir" blocked "PR $number blocked, merge conflicts, revisit: $title"; return 1 ;;
      BLOCKED/*) _land_finish "$dir" blocked "PR $number blocked, needs review, revisit: $title"; return 1 ;;
      *) _land_finish "$dir" blocked "PR $number in unexpected state $mstatus, revisit: $title"; return 1 ;;
    esac
    (( SECONDS - start > timeout * 60 )) && { _land_finish "$dir" timeout "timed out after ${timeout} minutes waiting on PR $number, revisit: $title"; return 1 }
    print -r -- $'watching\t'"$mstatus, checks $checks" > "$dir/status"
    echo "$(date +%H:%M) $mstatus, checks $checks"
    sleep 30
  done
}
_land_finish() { # dir kind message — record, log, and speak the outcome
  print -r -- "$2"$'\t'"$3" > "$1/status"
  echo "$(date +%H:%M) $3"
  local sound=Basso; [[ "$2" == merged ]] && sound=Hero
  afplay "/System/Library/Sounds/$sound.aiff"
  say "$3"
}
_land_status() {
  setopt localoptions nullglob
  local d kind msg elapsed
  local -a dirs=($LAND_DIR/*(/N))
  (( $#dirs )) || { echo "land: nothing queued"; return }
  for d in $dirs; do
    IFS=$'\t' read -r kind msg < "$d/status"
    elapsed=$(( ($(date +%s) - $(<"$d/start")) / 60 ))
    [[ "$kind" == watching ]] && { kill -0 "$(<"$d/pid")" 2>/dev/null || kind=died; msg="$msg: $(<"$d/title")" }
    printf '#%-6s %-9s %3dm  %s\n' "${d:t}" "$kind" "$elapsed" "$msg"
  done
}
_land_clear() { # drop finished jobs
  setopt localoptions nullglob
  local d kind
  for d in $LAND_DIR/*(/N); do
    IFS=$'\t' read -r kind _ < "$d/status"
    [[ "$kind" == watching ]] && kill -0 "$(<"$d/pid")" 2>/dev/null && continue
    rm -rf "$d"
  done
}
