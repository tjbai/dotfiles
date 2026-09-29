# TJ's machines

I work interactively on my laptop and on `work`, an always-on Mac mini at the office. A thread I start myself (TUI, CLI, or IDE) on either machine is a normal pair-programming session: run things locally, edit, build, test, commit, and leave state behind as the task calls for. Nothing below changes that.

## Reaching `work` from a remote thread

`work` runs a persistent Amp runner with ID `work`, cwd `/Users/bai/runner`. It is the only way an orb, Puck, or scheduled thread can reach state on that machine: `~/auctor` (Auctor monorepo checkout and worktrees; `~/auctor/scratch` is my Obsidian vault), `~/dev` (dotfiles, side projects), local credentials (Infisical, keychain, `gh`, AWS, Supabase, Porter), and local processes (Docker, Supabase, dev servers, launchd jobs).

When a remote task needs that state: `list_runners`; if `work` is listed, `create_thread` with `executor: runner`, `runner_id: work`, `intent: environment-access`. Give it one tight task with exact paths, commands, and the output you need, ask it to reply with `send_thread_message`, and keep working meanwhile. If `work` is not listed, say the desktop is offline and continue without it; do not poll or schedule retries unless I asked. Do not route compute an orb can do itself through the runner.

## When another thread spawned you onto `work`

This applies only when this thread was created by another thread for environment access, not when I started it. You are then on my real machine on someone else's behalf: do the requested task, leave no background processes, temp files, or checked-out branches behind; confirm with the requester before anything destructive; do not push unless the request says so; reply to the requesting thread with results and exact paths, then stop.

## Child threads

I run bigger programs as one parent thread that dispatches children with `create_thread`, and I read the tree by its titles. Keep them short and current.

- Title a child in 2–3 words, all lower-case, naming the job it owns: `census refresh`, `jev runner`, `input projection`, `fp-5 run`. A PR or issue number counts as a word (`preview #11320`, `triage AUC-7392`). No sentences, no colons, no restating the prompt. Fan-out siblings share a stem and differ by one word (`alerts chat`, `alerts tasks`).
- Set the title at creation with `create_thread`'s `title`. Rename with `update_thread` when the job drifts from the title, when a child outgrows its one-shot task into a long-running worker, or when I say the names are hard to grok. A rename that returns "Permission denied" is a child I own from another executor; tell me the intended title and move on.
- Archive children periodically, without waiting for me to ask: at natural checkpoints (after consuming a child's result, at handoff or compaction, when I ask what the children are doing) sweep the ones that are done. A child is done when its result is consumed, anything it produced is recorded somewhere durable (parent thread, scratch, PR), and `get_thread_status` shows it idle. Archive with `update_thread({ thread, archived: true })`. This section is my standing request to archive; the tool does not need a fresh one per thread.
- Do not archive a child that is still running, that is waiting on my input, or that I have been talking to directly unless I say so. When you are unsure whether a child is finished, list it as "done, safe to archive?" in the inventory instead of guessing.
- When I ask for an inventory, answer with one line per child: title, what it owns, state (running / idle / awaiting me), and whether it is safe to archive.

## Conventions on my machines

- launchd jobs are defined in `~/dev/dotfiles/launchd/jobs/<name>/`, applied with `lj apply`, inspected with `lj ls`, `lj status`, `lj log`, `lj doctor`. Never hand-write `~/Library/LaunchAgents`.
- my Amp settings (this guidance, Puck instructions, toggles) are tracked in `~/dev/dotfiles/amp/` and synced with `amp/sync`. Edit the repo copy and push with the script rather than the web UI.
