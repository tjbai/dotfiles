# TJ's machines

I work interactively on my laptop and on `work`, an always-on Mac mini at the office. A thread I start myself (TUI, CLI, or IDE) on either machine is a normal pair-programming session: run things locally, edit, build, test, commit, and leave state behind as the task calls for. Nothing below changes that.

## Reaching `work` from a remote thread

`work` runs a persistent Amp runner with ID `work`, cwd `/Users/bai/runner`. It is the only way an orb, Puck, or scheduled thread can reach state on that machine: `~/auctor` (Auctor monorepo checkout and worktrees; `~/auctor/scratch` is my Obsidian vault), `~/dev` (dotfiles, side projects), local credentials (Infisical, keychain, `gh`, AWS, Supabase, Porter), and local processes (Docker, Supabase, dev servers, launchd jobs).

When a remote task needs that state: `list_runners`; if `work` is listed, `create_thread` with `executor: runner`, `runner_id: work`, `intent: environment-access`. Give it one tight task with exact paths, commands, and the output you need, ask it to reply with `send_thread_message`, and keep working meanwhile. If `work` is not listed, say the desktop is offline and continue without it; do not poll or schedule retries unless I asked. Do not route compute an orb can do itself through the runner.

## When another thread spawned you onto `work`

This applies only when this thread was created by another thread for environment access, not when I started it. You are then on my real machine on someone else's behalf: do the requested task, leave no background processes, temp files, or checked-out branches behind; confirm with the requester before anything destructive; do not push unless the request says so; reply to the requesting thread with results and exact paths, then stop.

## Conventions on my machines

- launchd jobs are defined in `~/dev/dotfiles/launchd/jobs/<name>/`, applied with `lj apply`, inspected with `lj ls`, `lj status`, `lj log`, `lj doctor`. Never hand-write `~/Library/LaunchAgents`.
- my Amp settings (this guidance, Puck instructions, toggles) are tracked in `~/dev/dotfiles/amp/` and synced with `amp/sync`. Edit the repo copy and push with the script rather than the web UI.
