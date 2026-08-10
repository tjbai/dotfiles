---
name: previewing-markdown-in-orbs
description: Serves rendered, live-reloading markdown previews of workspace files (plans, specs, docs) through an Amp orb portal. Use when asked to preview markdown, show a plan or spec rendered, open a markdown portal, or track plan documents in an orb.
---

# Previewing Markdown in Orbs

Starts a zero-dependency Node server that renders the workspace's markdown through an orb portal: an index of all `.md` files sorted by last modified (active plans float to the top), GitHub-style rendering, Mermaid diagrams, and live reload while the agent edits a file.

## Start the preview

1. Copy the bundled server to a stable path so it survives skill cache refreshes:

```bash
mkdir -p ~/.local/share/md-preview
cp "$SKILL_DIR/scripts/md-preview-server.mjs" ~/.local/share/md-preview/server.mjs
```

Replace `$SKILL_DIR` with this skill's base directory as a plain filesystem path: strip the `file://` scheme and percent-decode the displayed base URI (`%40` → `@`, `%20` → space).

2. Start it as a supervised orb service from the workspace root (the server listens on `$PORT`, falling back to 4321):

```bash
amp orb service start md-preview --command "node ~/.local/share/md-preview/server.mjs --root <workspace-root>"
```

3. Get the portal URL for the port the service reports (check `amp orb service status md-preview` or its log line `md-preview serving ... on :<port>`):

```bash
amp orb portal <port>
```

Give the user that URL. `/` is the mtime-sorted index; each file renders at `/f/<relative-path>` and auto-refreshes about every 1.5s when the file changes.

## Notes

- Outside an orb, just run the server directly and open `http://localhost:4321`.
- Rendering happens client-side via CDN (`marked`, `mermaid`, `github-markdown-css`); the server has no npm dependencies.
- The index skips `.git`, `node_modules`, `.next`, `dist`, `build`, `worktrees`, `.venv`, and dot-directories.
