---
name: managing-launchd-jobs
description: Defines, applies, and inspects launchd user agents on TJ's Mac through the dotfiles-managed `lj` tool. Use when asked to add a background job, cron, or daemon on the laptop, to check whether a launchd job is running or healthy, or to read a job's log. Never hand-write ~/Library/LaunchAgents plists.
---

# Managing launchd jobs

All user launchd agents on this machine are defined in `~/dev/dotfiles/launchd/jobs/<name>/` and rendered into `~/Library/LaunchAgents/com.tjbai.<name>.plist` by `lj` (`~/dev/dotfiles/launchd/lj`, on PATH). The repo is the source of truth; `lj` owns every `com.tjbai.*` label and nothing else.

## Inspect

- `lj ls` — repo jobs with loaded state, pid, last exit, last run, run count. `--all` adds every other agent in the user domain, read-only.
- `lj status <name>` — full `launchctl print` for one job (also accepts any label).
- `lj log <name> [-f]` — `~/Library/Logs/tjbai/<name>.log`; each run is bracketed by `START` and `END exit=N dur=Ns` lines written by the wrapper.
- `lj doctor` — exit 1 if any job has drifted from its plist, is unloaded, failed its last run, is overdue for its interval, has a huge log, fails its `check` hook, or if an orphan `com.tjbai.*` plist exists.
- `lj run <name>` — start a run now (`kickstart -k`).

## Define a job

Create `~/dev/dotfiles/launchd/jobs/<name>/` with:

- `job` — bash-sourced spec. Exactly one trigger: `INTERVAL=<seconds>`, `CALENDAR="Hour=5 Minute=0"` (any StartCalendarInterval keys), or `KEEP_ALIVE=1` (daemon, restarted on exit). Optional `RUN_AT_LOAD=1`, `CWD=<dir>`, `DESC="..."`.
- `run` — the executable (`chmod +x`). It runs straight from the checkout via `lj _exec <name>`, which sets PATH, logs, records `~/.local/state/lj/<name>.last`, and notifies on non-zero exit. Edits to `run` are live on the next tick; only changes to `job` need `lj apply`.
- `check` — optional executable doctor hook; exit non-zero with a one-line reason to make `lj doctor` flag the job.

Then `lj apply` (or `lj apply --prune` to also unload labels the repo no longer defines), `lj ls` to confirm it loaded, and commit the dotfiles change. Do not push unless asked.

## Rules

- Never write or edit `~/Library/LaunchAgents/*.plist` directly, and never `launchctl load` a hand-made plist. Define the job in the repo and `lj apply`.
- `lj disable <name>` / `lj enable <name>` to pause a job; deleting its directory plus `lj apply --prune` removes it.
- Existing jobs: `amp-runner` (keeps the `bai-mbp` Amp runner alive) and `amp-runner-refresh` (5am restart onto a newer amp binary when idle). Do not stop `amp-runner` from a remote thread; it is the remote thread's only path to this machine.
