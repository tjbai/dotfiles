---
name: debugging-firefox-with-playwright
description: Uses Playwright MCP to inspect and debug live web pages in Firefox. Use when browser automation, DOM inspection, console or network checks, screenshots, or issue reproduction in Firefox is needed.
---

# Debugging Firefox With Playwright

Use the bundled Playwright MCP tools when a live Firefox browser is the fastest way to verify page state instead of guessing from source.

## Use It For

- Reproducing UI bugs in a real browser session.
- Inspecting live page structure with `browser_snapshot`.
- Checking computed state with `browser_evaluate` or `browser_run_code`.
- Reviewing console output and network requests.
- Taking screenshots while debugging visual issues.

## Workflow

0. Ensure the shared Playwright MCP server is running before using any browser tool. Check with `curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8931/mcp`; any HTTP response means it is up. If the connection is refused, start it in the background and wait for it to accept connections:

   ```bash
   nohup npx @playwright/mcp@latest --browser=firefox --host 127.0.0.1 --port 8931 \
     --allowed-hosts 127.0.0.1:8931,localhost:8931 \
     --user-data-dir "$HOME/.local/share/playwright-mcp/firefox" > /tmp/playwright-mcp.log 2>&1 &
   for i in $(seq 1 20); do curl -s -o /dev/null http://127.0.0.1:8931/mcp && break; sleep 0.5; done
   ```

   Every flag matters. `--host 127.0.0.1` because the default binds `::1` only and the `mcp.json` URL is `127.0.0.1`. `--user-data-dir` because without it Playwright MCP derives the profile from `sha256(client cwd)`, so each thread cwd gets a fresh, logged-out Firefox. The pinned profile already holds logins (ampcode.com, google); if a site asks to log in, do it once in this browser (`browser_snapshot` + `browser_type`, or tell the user to take over) and it persists. The server was started by some earlier thread; if it is up but on the wrong flags (`ps -eo command | rg playwright-mcp`), kill it and restart with the command above.

1. Start with `browser_navigate` or `browser_tabs` to open the target page.
2. Use `browser_snapshot` before interacting so element refs stay deterministic.
3. Use `browser_console_messages`, `browser_network_requests`, and `browser_evaluate` to root-cause issues instead of inferring from appearance alone.
4. Use `browser_take_screenshot` only when a visual artifact is helpful to confirm what the browser is rendering.
5. Close the session with `browser_close` when done.

## Notes

- This skill launches Playwright in Firefox mode; it does not attach to an already-open personal Firefox session.
- Prefer `browser_snapshot` over screenshots for most inspection because it is cheaper and more reliable for interaction.
- Use `browser_run_code` only when the built-in tools are too limited for the inspection task.
