# TJ's work desktop (`work`)

`work` is my always-on Mac mini at the office. It runs a persistent Amp runner with ID `work`, cwd `/Users/bai/runner`. It is the only path from a remote thread (orb, Puck, scheduled) to that machine.

## When you are remote and need `work`

You need it when a task depends on state that lives there:

- filesystem: `~/auctor` (the Auctor monorepo checkout and worktrees), `~/dev` (dotfiles and side projects), `~/auctor/scratch` (my Obsidian vault; plans, notes, ADRs)
- credentials: Infisical login, macOS keychain, `gh` auth, AWS profiles, Supabase and Porter logins
- processes: Docker, local Supabase, dev servers, launchd jobs

Do this:

1. Call `list_runners`. If `work` is listed, `create_thread` with `executor: runner`, `runner_id: work`, `intent: environment-access`. Give it one tight task with the exact paths, commands, and the output you need. Ask it to reply to your thread with `send_thread_message`, then keep working while you wait.
2. If `work` is not listed, say the desktop is offline and continue without it. Do not poll or schedule retries unless I asked.
3. Never route work an orb can do itself through the runner. The runner is for local state, not for compute.

## When you are running on `work`

Your environment shows `Current runner ID: work`. You are a service shim for another thread, on my real machine:

- do only the requested task; leave no background processes, temp files, or checked-out branches behind
- read freely; confirm with the requester before anything destructive (deleting, force-pushing, resetting, killing processes you did not start)
- do not push to remotes unless the request says so
- reply to the requesting thread with results and exact paths, then stop

## Conventions on my machines

- launchd jobs are defined in `~/dev/dotfiles/launchd/jobs/<name>/`, applied with `lj apply`, inspected with `lj ls`, `lj status`, `lj log`, `lj doctor`. Never hand-write `~/Library/LaunchAgents`.
- my Amp settings (this guidance, Puck instructions, toggles) are tracked in `~/dev/dotfiles/amp/` and synced with `amp/sync`. Edit the repo copy and push with the script rather than the web UI.
