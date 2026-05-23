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
alias lsmd="ls -d *.md 2>/dev/null"
alias npm="pnpm"
alias ghpr="gh pr create --base"
alias chat="PYTHONWARNING=\"ignore\" uvpy scripts/run/chat.py"
alias rlm="PYTHONWARNING=\"ignore\" uvpy scripts/run/rlm_cli.py"
alias tsc="npx tsc --noEmit -p tsconfig.json"
alias codexh="codex --model=gpt-5-codex -c model_reasoning_effort=\"high\""
alias resap="cd api && rm -rf .venv && rm -rf uv.lock && uv sync --no-cache && cd .."
alias ng="ngrok http 3000 --domain=dev.getauctor.com"
alias check="pnpm check && pnpm check:trpc && pnpm dlx react-doctor@latest . --diff origin/dev --fail-on error"
alias format="pnpm format:changed"
alias fish="ssh tbai4@login.rockfish.jhu.edu -t 'bash --noprofile --norc -c \"source /etc/profile.d/modules.sh && module load zsh && zsh && source ~/.bashrc\"'"
alias perl="ssh perl -i ~/.ssh/nersc"
alias perlog="sshproxy -f"
alias kall="npm kill"
alias test="uvpy -m pytest"
alias temprun="uv run --project temporal python temporal/scripts/local_task_runner_repl.py --allow-all"

_auctor_temporal_db_up() {
  local root="${1:-${AUCTOR_DEMO_ROOT:-$HOME/auctor/demo}}"
  local env_file="$root/.env"
  local local_db_url

  if [[ ! -d "$root/temporal" ]]; then
    echo "db: could not find temporal dir at $root/temporal" >&2
    return 1
  fi
  if [[ -f "$env_file" ]]; then
    set -a
    source "$env_file"
    set +a
  fi
  if [[ -z "$TEMPORAL_DATABASE_URL" ]]; then
    local_db_url="$(cd "$root" && supabase status -o env 2>/dev/null | sed -n 's/^DB_URL=//p' | tr -d '"')"
    export TEMPORAL_DATABASE_URL="${local_db_url:-${DIRECT_URL:-$DATABASE_URL}}"
  fi
  if [[ -z "$TEMPORAL_DATABASE_URL" ]]; then
    echo "db: TEMPORAL_DATABASE_URL, DIRECT_URL, or DATABASE_URL must be set" >&2
    return 1
  fi
  (cd "$root/temporal" && arch -arm64 uv run alembic upgrade head)
}

db() {
  local cmd="$1"
  shift || true
  local root="${AUCTOR_DEMO_ROOT:-$HOME/auctor/demo}"

  case "$cmd" in
    reset)
      (cd "$root" && supabase db reset "$@") && _auctor_temporal_db_up "$root"
      ;;
    up)
      (cd "$root" && supabase migration up "$@") && _auctor_temporal_db_up "$root"
      ;;
    temporal-up)
      _auctor_temporal_db_up "$root"
      ;;
    *)
      echo "Usage: db {reset|up|temporal-up} [supabase args...]" >&2
      return 2
      ;;
  esac
}

sapiensmode() {
  local mode="${1:-toggle}"
  local root="${2:-$HOME/auctor/demo}"

  python3 - "$mode" "$root" <<'PY'
import pathlib
import sys

mode = sys.argv[1]
root = pathlib.Path(sys.argv[2]).expanduser()
files = [root / "api" / "pyproject.toml", root / "temporal" / "pyproject.toml"]
pin = '    "auctor-sapiens @ git+https://github.com/AuctorAI/sapiens.git@v4.17.9",'
local_dep = '    "auctor-sapiens",'
source = 'auctor-sapiens = { path = "../../sapiens", editable = true }'

if mode not in {"toggle", "local", "pin", "pinned", "git", "status"}:
    print("Usage: sapiensmode [local|pin|toggle|status] [repo-root]", file=sys.stderr)
    raise SystemExit(2)

def is_local(text: str) -> bool:
    return f"\n{local_dep}\n" in text and f"\n{source}\n" in text

if mode == "status":
    for path in files:
        print(f"{path}: {'local' if is_local(path.read_text()) else 'pin'}")
    raise SystemExit(0)

if mode == "toggle":
    mode = "pin" if is_local(files[0].read_text()) else "local"

if mode in {"pinned", "git"}:
    mode = "pin"

for path in files:
    text = path.read_text()
    lines = text.splitlines()
    out = []
    in_deps = False
    inserted_dep = False
    skipped_dep = False
    for line in lines:
        if line == "dependencies = [":
            in_deps = True
            out.append(line)
            continue
        if in_deps and line == "]":
            if skipped_dep and not inserted_dep:
                out.extend([local_dep, f"    # {pin.strip()}"] if mode == "local" else [f"    # {local_dep.strip()}", pin])
            in_deps = False
            out.append(line)
            continue
        if in_deps and "auctor-sapiens" in line:
            if not inserted_dep:
                out.extend([local_dep, f"    # {pin.strip()}"] if mode == "local" else [f"    # {local_dep.strip()}", pin])
                inserted_dep = True
            skipped_dep = True
            continue
        out.append(line)

    text = "\n".join(out) + "\n"
    lines = text.splitlines()
    out = []
    in_sources = False
    saw_sources = False
    inserted_source = False
    for line in lines:
        if line == "[tool.uv.sources]":
            in_sources = True
            saw_sources = True
            out.append(line)
            continue
        if in_sources and line.startswith("["):
            if not inserted_source:
                out.append(source if mode == "local" else f"# {source}")
            in_sources = False
            out.append(line)
            continue
        if in_sources and "auctor-sapiens" in line and "sapiens" in line:
            if not inserted_source:
                out.append(source if mode == "local" else f"# {source}")
                inserted_source = True
            continue
        out.append(line)
    if in_sources and not inserted_source:
        out.append(source if mode == "local" else f"# {source}")
    if not saw_sources:
        for i, line in enumerate(out):
            if line.startswith("[") and line != "[tool.uv]" and i > 0 and out[i - 1] == "exclude-newer = \"7 days\"":
                out[i:i] = ["", "[tool.uv.sources]", source if mode == "local" else f"# {source}"]
                break
    path.write_text("\n".join(out) + "\n")

print(f"sapiensmode: {mode}")
PY
}

tempcheck() {
  local temporal_dir
  local fix=0

  if [[ "$1" == "--fix" ]]; then
    fix=1
    shift
  fi

  if [[ $# -gt 0 ]]; then
    echo "Usage: tempcheck [--fix]" >&2
    return 2
  fi

  if [[ -d "./temporal" ]]; then
    temporal_dir="./temporal"
  else
    temporal_dir="$HOME/auctor/demo/temporal"
  fi

  if [[ ! -d "$temporal_dir" ]]; then
    echo "tempcheck: could not find temporal dir at ./temporal or $HOME/auctor/demo/temporal" >&2
    return 1
  fi

  if [[ "$fix" -eq 1 ]]; then
    (
      cd "$temporal_dir" && \
        uv run ruff check --fix src/auctor_temporal tests && \
        uv run ruff format src/auctor_temporal tests && \
        uv run basedpyright && \
        uv run python scripts/check_stage_imports.py --strict && \
        uv run python lint_temporal_db.py && \
        uv run semgrep --config .semgrep --error --quiet src/auctor_temporal tests && \
        uv run semgrep --config semgrep/temporal-db.yml --error --quiet src tests
    )
  else
    (
      cd "$temporal_dir" && \
        uv run ruff check src/auctor_temporal tests && \
        uv run ruff format --check src/auctor_temporal tests && \
        uv run basedpyright && \
        uv run python scripts/check_stage_imports.py --strict && \
        uv run python lint_temporal_db.py && \
        uv run semgrep --config .semgrep --error --quiet src/auctor_temporal tests && \
        uv run semgrep --config semgrep/temporal-db.yml --error --quiet src tests
    )
  fi
}

lsp() { lsof -i :$1 }
klsp() { lsof -i :$1 | awk 'NR>1 {print $2}' | xargs -r kill -9 }
gaws() { git diff -U0 -w --no-color "$@" | git apply --cached --ignore-whitespace --unidiff-zero - }

desc() {
  local pr="$1"
  if [[ -z "$pr" || ! "$pr" =~ ^[0-9]+$ ]]; then
    echo "Usage: desc <pr-number> [ref]"
    return 1
  fi

  local ref="${2:-$(git branch --show-current)}"
  gh workflow run devin-pr-description.yml \
    --repo AuctorAI/auctor \
    --ref "$ref" \
    -f pr_number="$pr"
}

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
