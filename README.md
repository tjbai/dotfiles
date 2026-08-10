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

amp: settings.json plus hand-written plugins from `~/.config/amp/plugins/`. plugins
that amp auto-updates from ampcode.com (marked on their first line) are skipped —
they restore themselves. `./install` curl-installs the amp cli if missing.

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
vault/        everything encrypted, nothing home-mirrored:
  private/    encrypted private files
  firefox/    encrypted bookmarks + search shortcuts
  raycast/    encrypted raycast settings export (.rayconfig)
.config/      plaintext configs
```

want more hidden? add a line to `private.txt` (or move shell config into
`~/.zshrc.private`). encrypts on the next `./update`.
