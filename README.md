a hypebeast's dotfiles: zsh, tmux, nvim, neovide, zed, ghostty, amp, firefox, raycast, skills.

## how it works

`./update` is a one-way push: live configs into the repo, private stuff encrypted, so
the repo can stay public. `./install` is the reverse, for a new machine.

configs (zsh, tmux, nvim, neovide, zed, ghostty, amp) are copied plaintext.

tmux: one session per unit of work (`wu <name>` in zsh), each ghostty tab attaches to
one. sessions survive ghostty quitting; resurrect+continuum autosave layout/cwd so a
reboot restores the shape (agents restart via `amp threads continue`). bells propagate
to ghostty tab indicators; `wu` with no args is the attention dashboard. `./install`
brew-installs tmux and clones the two plugins if missing.

amp: settings.json, custom themes (`~/.config/amp/themes/<name>/colors.toml`, ported
from the sentinel palettes), and hand-written plugins from `~/.config/amp/plugins/`.
plugins that amp auto-updates from ampcode.com (marked on their first line) are
skipped — they restore themselves. `./install` curl-installs the amp cli if missing.

ampcode.com has no theme setting, so `amp-web-themes/` themes it from firefox via
stylus. `bun build.ts` emits one `.user.css` per sentinel palette plus
`stylus-import.json`; stylus → manage → import styles loads all six (kanagawa on,
rest off; flip in the popup). the site keys its palette off css vars on `:root`
with `light-dark()`, so every override is `!important` to beat the built-in
`data-amp-theme` variants.

when the amp cli is authenticated, `./update` also mirrors local skills and plugins
into the amp user repos (`ampcode.com/git/@<user>/-/skills` and `/plugins`), which
every amp session — this machine, runners, fresh orbs — syncs from automatically.
local is the source of truth: anything living only in the amp repo gets deleted on
the next update. it also refreshes the zshrc bundled inside the `installing-dotfiles`
skill from the live `~/.zshrc`, so orbs installing dotfiles never drift. unauthenticated
runs just print a skip line and continue.

amp settings that live on ampcode.com, not on disk — `global_agent_guidance`
(my personal AGENTS.md, in every thread), `puck_instructions`, dictation vocabulary,
and the toggles/project defaults — are tracked in `amp/` and moved with `amp/sync
pull|push|check`. the repo is canonical: edit `amp/*.md`, `amp/sync push`. there's
no cli for these, only the amp tool inside a thread, so pull/push drive a low-mode
`amp -x` thread (~1 min, archived after) and re-pull to verify. `./install` pushes;
`./update` only reports drift (`UPDATE_SKIP_AMP_SYNC=1` to skip the thread).
`amp/secrets.txt` is names only — orb secrets can't be exported, it's a checklist.

launchd: every user agent is a directory under `launchd/jobs/<name>/` (`job` spec +
`run` script + optional `check`), rendered to `~/Library/LaunchAgents/com.tjbai.*`
by `launchd/lj` (symlinked to `~/.local/bin/lj` by install). scripts run live from
the checkout; `lj apply` only when the spec changes. `HOSTS="work"` in a spec pins
a job to those machines (short hostname); elsewhere `lj` ignores and prunes it, so
one repo serves the work mac mini (`work`) and everything else. `lj ls`, `lj status`, `lj log`,
`lj doctor` read health from the wrapper's logs and state, since launchd itself
barely remembers anything. `./install` applies (`--prune` drops labels the repo
doesn't define); `./update` runs `lj doctor`. jobs today: `amp-runner` keeps the
`work` amp runner up so orbs and puck can reach the work mac mini; `amp-runner-refresh`
restarts it onto a newer amp binary at 5am if nothing is working.

skills always keep their names. the generic ones listed in `public.txt` get published
in full (plaintext dir under `skills/<name>`). everything else — anything that reveals
work — becomes `skills/<name>.enc`: name visible, content encrypted. flip a skill
between the two by adding/removing it from `public.txt`.

firefox: `./update` flips `browser.bookmarks.autoExportHTML` in the profile's
`user.js`, so firefox rewrites `bookmarks.html` (bookmarks + keyword shortcuts) on
every quit; update encrypts that plus `search.json.mozlz4` (search engine shortcuts)
into `vault/firefox/`. `./install` decrypts them back and sets the one-shot import pref, so
bookmarks appear on next launch. firefox must be closed during install. first-ever
export needs one firefox restart after running update.

`firefox/amp-tweaks/` is a css-only extension for ampcode.com that pushes it toward
`~/dev/aui`: kills the floating selection toolbar (reply/dictate/copy/link), swaps the
body font to a bundled Inter Variable (450, cv01/ss03), pins `--amp-text-size-scale`
to .92 (~12px body, what 80% zoom felt like, without zoom shrinking the column), rewrites the transcript markdown rhythm (obsidian-style block gaps, flat
600-weight headings, hairline pre), flattens the user-message glow (`.alchemy-glow`),
and widens the reading column from amp's 39rem to `--tj-column` (54rem = 864px).
load it from `about:debugging#/runtime/this-firefox` → "Load Temporary Add-on…" →
pick `manifest.json`; it's gone on restart, reload it. edit `amp.css`, hit "Reload"
there. keybinds are not css: those live in amp's own keymap (`keyboard_shortcuts` in
`amp/settings.json`, synced like the rest). thread next/prev is `ctrl+]` / `ctrl+[`
because firefox handles ctrl+tab, cmd+shift+[ ], and cmd+opt+arrows in its system
event group and ignores the page's preventDefault, so amp never sees them.

raycast: no headless export, so it's a two-step. run "Export Settings & Data" in
raycast (save to ~/Downloads or ~/Desktop), then `./update` picks up the newest
.rayconfig and re-encrypts it into `vault/raycast/` with the dotfiles password (raycast's
own export passphrase might be weak, and this repo is public). `./install` brew-installs
raycast if missing, decrypts the config to ~/Downloads, and opens it — raycast prompts
for its export passphrase (its own, not the dotfiles one) and a category checklist.

private files are listed in `private.txt` and encrypted into `vault/private/`. today that's
just `~/.zshrc.private`, which my public `.zshrc` sources at the end (keeps the
committed `.zshrc` generic).

openssl aes-256-cbc, pbkdf2, one password for everything. let it prompt, or drop
`DOTFILES_PASSWORD=...` in an untracked `.env`.

## new machine

```sh
git clone <this repo> && cd dotfiles
./install
```

prompts for the password (or reads `.env`), and i have my shit back.

## layout

```
update        push: configs + encrypt skills + encrypt private files
install       pull: restore configs + decrypt everything
crypto        shared password + openssl, sourced by both
public.txt    skills safe to publish in full (everything else is encrypted)
private.txt   $HOME-relative files to encrypt
skills/       skills — <name>/ plaintext if public, <name>.enc if not
amp/          server-side amp settings: sync script, guidance + puck .md, settings.json, secret names
launchd/      lj (the tool) + jobs/<name>/{job,run,check}
firefox/      amp-tweaks/ — css-only extension for ampcode.com, loaded via about:debugging
vault/        everything encrypted, nothing home-mirrored:
  private/    encrypted private files
  firefox/    encrypted bookmarks + search shortcuts
  raycast/    encrypted raycast settings export (.rayconfig)
.config/      plaintext configs
```

want more hidden? add a line to `private.txt` (or move shell config into
`~/.zshrc.private`). encrypts on the next `./update`.
