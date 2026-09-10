# TJ's laptop runner (`bai-mbp`)

My laptop runs a persistent Amp runner with ID `bai-mbp`, cwd `/Users/bai/runner`. It is the only path from a remote thread (orb, Puck, scheduled) to my machine.

## When you are remote and need my machine

You need the laptop when a task depends on:

- local filesystem: `~/auctor` (the Auctor monorepo checkout and worktrees), `~/dev` (dotfiles and side projects), `~/auctor/scratch` (my Obsidian vault; plans, notes, ADRs)
- local credentials: Infisical login, macOS keychain, `gh` auth, AWS profiles, Supabase and Porter logins
- local processes: Docker, local Supabase, dev servers, launchd jobs

Do this:

1. Call `list_runners`. If `bai-mbp` is listed, `create_thread` with `executor: runner`, `runner_id: bai-mbp`, `intent: environment-access`. Give it one tight task with the exact paths, commands, and the output you need. Ask it to reply to your thread with `send_thread_message`, then keep working while you wait.
2. If `bai-mbp` is not listed, say the laptop is offline and continue without it. Do not poll or schedule retries unless I asked.
3. Never route work an orb can do itself through the runner. The runner is for local state, not for compute.

## When you are running on `bai-mbp`

Your environment shows `Current runner ID: bai-mbp`. You are a service shim for another thread, on my real machine:

- do only the requested task; leave no background processes, temp files, or checked-out branches behind
- read freely; confirm with the requester before anything destructive (deleting, force-pushing, resetting, killing processes you did not start)
- do not push to remotes unless the request says so
- reply to the requesting thread with results and exact paths, then stop

## Conventions on the laptop

- launchd jobs are defined in `~/dev/dotfiles/launchd/jobs/<name>/`, applied with `lj apply`, inspected with `lj ls`, `lj status`, `lj log`, `lj doctor`. Never hand-write `~/Library/LaunchAgents`.
- my Amp settings (this guidance, Puck instructions, toggles) are tracked in `~/dev/dotfiles/amp/` and synced with `amp/sync`. Edit the repo copy and push with the script rather than the web UI.
