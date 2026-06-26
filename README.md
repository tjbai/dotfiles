a hypebeast's dotfiles: zsh, nvim, neovide, zed, ghostty, skills.

## how it works

`./update` is a one-way push: live configs into the repo, private stuff encrypted, so
the repo can stay public. `./install` is the reverse, for a new machine.

configs (zsh, nvim, neovide, zed, ghostty) are copied plaintext.

skills always keep their names. the generic ones listed in `public.txt` get published
in full (plaintext dir under `skills/<name>`). everything else — anything that reveals
work — becomes `skills/<name>.enc`: name visible, content encrypted. flip a skill
between the two by adding/removing it from `public.txt`.

private files are listed in `private.txt` and encrypted into `private/`. today that's
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
private/      encrypted private files
.config/      plaintext configs
```

want more hidden? add a line to `private.txt` (or move shell config into
`~/.zshrc.private`). encrypts on the next `./update`.
