a hypebeast's dotfiles: zsh, tmux, nvim, neovide, zed, ghostty, amp, firefox, raycast, launchd, skills.

tl;dr `./update` pushes live configs into the repo, `./install` pulls them back onto a new machine. anything private or work-revealing gets encrypted on the way in, so the repo can just stay public.

## how it works

`./update` is one-way: live configs -> repo, private stuff encrypted. `./install` is the reverse. the plaintext configs (zsh, tmux, nvim, neovide, zed, ghostty, amp) are just copied. everything else is openssl aes-256-cbc + pbkdf2 with one password for everything — let it prompt, or drop `DOTFILES_PASSWORD=...` in an untracked `.env`.

zsh: the interesting stuff is functions, not aliases. `nv` opens neovide, or, if one it launched is still alive, attaches over a socket and opens a new tab there instead of spawning another window. pass it a branch or a PR URL and it checks out first via `gco`, which just `cd`s into the branch's worktree if it already has one. `land <pr> [minutes]` babysits a PR in the background — waits on CI, updates the branch when it's behind, merges with `ghm` — and says the outcome out loud. `land` lists jobs, `land clear` drops finished ones, `land cancel <n>` kills one.

tmux: tuned for the amp cli (passthrough, hyperlinks, extended keys, shift+enter as CSI-u). bells pass through to ghostty's tab indicator; activity only flags the status line, because agents stream constantly and a bell per write is noise. resurrect + continuum autosave layout / cwd every 10 min, so a reboot restores the shape (agents come back with `amp threads continue`). `./install` brew-installs tmux and clones both plugins if missing.

allnight: `allnight [hours] [fish|wave]` runs caffeinate, optionally with a screensaver. `fish` is asciiquarium. brew's build paints opaque black behind every cell, which kills ghostty's transparency, so `patches/asciiquarium-transparent-bg.patch` swaps the bundled Term::Animation over to the terminal's default background. `./install` brew-installs and applies it; a `brew upgrade` silently drops it and `./update` tells you. `wave` is `bin/kanagawa`, the great wave in braille: a height-field swell with two rolling waves whose crests curl into hokusai claws, fuji and a moon behind them, 24-bit color on the default background. colors come from the sentinel palettes in `~/.config/amp/themes` and drift kanagawa -> nordfox -> catppuccin -> rosepine -> everforest -> gruvbox, one every 20 min (`--cycle`); the moon crosses the sky over `--hours`. stdlib python, nothing to install. keys: `q`/esc quit, `n`/`→` next palette, `p`/`←` previous, `1`–`6` pick one, space holds the drift, `h` hides the clock. `--theme gruv` starts on a palette, `--hold` stays there, `--bench` times a frame headless.

amp: settings.json, custom tui themes (`~/.config/amp/themes/<name>/colors.toml`, ported from the six sentinel palettes), and hand-written plugins from `~/.config/amp/plugins/`. plugins that amp auto-updates from ampcode.com (marked on their first line) are skipped — they restore themselves. `./install` curl-installs the amp cli if missing.

when the amp cli is authenticated, `./update` also mirrors local skills and plugins into the amp user repos (`ampcode.com/git/@<user>/-/skills` and `/plugins`), which every amp session — this machine, runners, fresh orbs — syncs from automatically. local is the source of truth: anything living only in the amp repo gets deleted on the next update. it also refreshes the zshrc bundled inside the `installing-dotfiles` skill from the live `~/.zshrc`, so orbs that install dotfiles never drift. unauthenticated runs just print a skip line and move on.

amp settings that live on ampcode.com, not on disk — `global_agent_guidance` (my personal AGENTS.md, in every thread), `puck_instructions`, dictation vocabulary, and the toggles / project defaults — are tracked in `amp/` and moved with `amp/sync pull|push|check`. the repo is canonical: edit `amp/*.md`, then `amp/sync push`. there's no cli for these, only the amp tool inside a thread, so pull / push drive a low-mode `amp -x` thread (~1 min, archived after) and re-pull to verify. `./install` pushes; `./update` only reports drift (`UPDATE_SKIP_AMP_SYNC=1` skips the thread). `amp/secrets.txt` is names only — orb secrets can't be exported, so it's just a checklist.

ampcode.com has no theme setting, so `firefox/stylus/ampcode/` themes it from firefox via stylus (one dir per site under `firefox/stylus/`). `bun build.ts` emits one `.user.css` per palette plus `stylus-import.json`. there are 14: the six dark ones mirror the sentinel palettes, and the eight light ones (flexoki, modus operandi, github, gruvbox light, catppuccin latte, kanagawa lotus, rosé pine dawn, dayfox) are each scheme's own light variant or a palette built for reading on paper, picked for ≥7:1 body-text contrast where the scheme has it. stylus -> manage -> import styles loads all of them (kanagawa on, rest off; flip in the popup). the site keys its palette off css vars on `:root` with `light-dark()`, so every override is `!important` to beat the built-in `data-amp-theme` variants.

`firefox/amp-tweaks/` is a css-only extension for ampcode.com that pushes it toward `~/dev/aui`. it (1) kills the floating selection toolbar (reply / dictate / copy / link), (2) swaps the body font to a bundled Inter Variable (450, cv01/ss03), (3) pins `--amp-text-size-scale` to .92 (~12px body, what 80% zoom felt like, without zoom shrinking the column), (4) rewrites the transcript markdown rhythm (obsidian-style block gaps, flat 600-weight headings, hairline pre), (5) flattens the user-message glow (`.alchemy-glow`), (6) widens the reading column from amp's 39rem to `--tj-column` (54rem = 864px), (7) cleans up the sidebar — unread rows get loud (accent title, bigger dot) and collapsed group headers drop their running / unread status dots, and (8) hides the quick-action chips above the composer (diff stat, ship, open portal, …). load it from `about:debugging#/runtime/this-firefox` -> "Load Temporary Add-on…" -> pick `manifest.json`. it's gone on restart, so reload it. edit `amp.css`, hit "Reload" there.

keybinds aren't css: those live in amp's own keymap (`keyboard_shortcuts` in `amp/settings.json`, synced like the rest). thread next / prev is `ctrl+]` / `ctrl+[` because firefox handles ctrl+tab, cmd+shift+[ ], and cmd+opt+arrows in its system event group and ignores the page's preventDefault, so amp never even sees them.

launchd: every user agent is a directory under `launchd/jobs/<name>/` (`job` spec + `run` script + optional `check`), rendered to `~/Library/LaunchAgents/com.tjbai.*` by `launchd/lj` (symlinked to `~/.local/bin/lj` by install). scripts run live from the checkout, so `lj apply` is only needed when the spec changes. `HOSTS="work"` in a spec pins a job to those machines (short hostname); elsewhere `lj` ignores and prunes it, so one repo serves the work mac mini (`work`) and everything else. `lj ls`, `lj status`, `lj log`, `lj doctor` read health from the wrapper's logs and state, since launchd itself barely remembers anything. `./install` applies (`--prune` drops labels the repo doesn't define); `./update` runs `lj doctor`. jobs today, both pinned to `work`:

- `amp-runner` keeps the `work` amp runner up so orbs and puck can reach the work mac mini. upgrades are amp's own problem now — `amp.runner.autoUpdate.enabled` re-execs the runner in place when it's idle, which obviated the old 5am refresh job.
- `scratch-fold` runs hourly. every scratch checkout (orbs, the vault, the laptop) commits and pushes to `inbox`; this rewrites that stream onto `main` as one commit per project dir per closed 4h UTC window. nothing is pushed unless the folded tree is byte-identical to inbox, and its `check` flags the vault drifting off `inbox` or github's default branch drifting off it.

skills always keep their names. the generic ones listed in `public.txt` get published in full (plaintext dir under `skills/<name>`). everything else — anything that reveals work — becomes `skills/<name>.enc`: name visible, content encrypted. flip a skill between the two by adding / removing it from `public.txt`.

firefox: `./update` flips `browser.bookmarks.autoExportHTML` in the profile's `user.js`, so firefox rewrites `bookmarks.html` (bookmarks + keyword shortcuts) on every quit; update encrypts that plus `search.json.mozlz4` (search engine shortcuts) into `vault/firefox/`. `./install` decrypts them back and sets the one-shot import pref, so bookmarks appear on next launch. firefox must be closed during install, and the first-ever export needs one firefox restart after running update.

raycast: no headless export, so it's a two-step. run "Export Settings & Data" in raycast (save to ~/Downloads or ~/Desktop), then `./update` picks up the newest .rayconfig and re-encrypts it into `vault/raycast/` with the dotfiles password (raycast's own export passphrase might be weak, and this repo is public). `./install` brew-installs raycast if missing, decrypts the config to ~/Downloads, and opens it — raycast prompts for its export passphrase (its own, not the dotfiles one) and a category checklist.

private files are listed in `private.txt` and encrypted into `vault/private/`. today that's just `~/.zshrc.private`, which the public `.zshrc` sources at the end (keeps the committed `.zshrc` generic).

## new machine

```sh
git clone https://github.com/tjbai/dotfiles && cd dotfiles
./install
```

prompts for the password (or reads `.env`), and i have my shit back.

## layout

```
update        push: configs + encrypt skills + encrypt private files + amp publish
install       pull: restore configs + decrypt everything + lj apply
crypto        shared password + openssl, sourced by both
public.txt    skills safe to publish in full (everything else is encrypted)
private.txt   $HOME-relative files to encrypt
skills/       skills — <name>/ plaintext if public, <name>.enc if not
amp/          server-side amp settings: sync script, guidance + puck .md, settings.json, secret names
launchd/      lj (the tool) + jobs/<name>/{job,run,check}
firefox/      amp-tweaks/ — css-only extension for ampcode.com, loaded via about:debugging
  stylus/     userstyles, one dir per site; ampcode/ has build.ts + the 14 palettes
bin/          kanagawa — the wave screensaver behind `allnight wave`
patches/      asciiquarium transparent-background patch, applied by install
vault/        everything encrypted, nothing home-mirrored:
  private/    encrypted private files
  firefox/    encrypted bookmarks + search shortcuts
  raycast/    encrypted raycast settings export (.rayconfig)
.config/      plaintext configs (amp/ includes tui themes + hand-written plugins)
```

want more hidden? add a line to `private.txt` (or move shell config into `~/.zshrc.private`). it encrypts on the next `./update`.
