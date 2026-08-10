#!/usr/bin/env node
import { createServer } from 'node:http'
import { readFile, stat, readdir } from 'node:fs/promises'
import { resolve, join, relative, extname } from 'node:path'

const args = process.argv.slice(2)
const rootIdx = args.indexOf('--root')
const ROOT = resolve(rootIdx >= 0 ? args[rootIdx + 1] : process.cwd())
const PORT = Number(process.env.PORT || 4321)
const SKIP = new Set(['.git', 'node_modules', '.next', 'dist', 'build', 'worktrees', '.venv', '.cache'])

async function listMarkdown(dir, out = []) {
  let entries
  try {
    entries = await readdir(dir, { withFileTypes: true })
  } catch {
    return out
  }
  for (const e of entries) {
    if (e.name.startsWith('.') && e.name !== '.agents') continue
    if (SKIP.has(e.name)) continue
    const full = join(dir, e.name)
    if (e.isDirectory()) await listMarkdown(full, out)
    else if (extname(e.name).toLowerCase() === '.md') {
      const s = await stat(full)
      out.push({ path: relative(ROOT, full), mtime: s.mtimeMs })
    }
  }
  return out
}

function safePath(rel) {
  const full = resolve(ROOT, rel)
  if (!full.startsWith(ROOT + '/') && full !== ROOT) return null
  return full
}

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

const PAGE = (title, body, script = '') => `<!doctype html>
<html><head><meta charset="utf-8"><title>${esc(title)}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css@5/github-markdown.min.css">
<style>
body{margin:0;background:#0d1117}
.markdown-body{box-sizing:border-box;max-width:920px;margin:0 auto;padding:32px 48px;min-height:100vh}
a{color:#4da3ff}
.idx{list-style:none;padding:0}.idx li{padding:4px 0;font-family:ui-monospace,monospace;font-size:14px}
.idx .t{color:#8b949e;font-size:12px;margin-left:8px}
.crumb{font-family:ui-monospace,monospace;font-size:12px;padding:8px 48px;color:#8b949e}
.crumb a{text-decoration:none}
</style></head>
<body><div class="crumb"><a href="/">index</a></div><article class="markdown-body">${body}</article>
<script type="module">${script}</script></body></html>`

const VIEW_SCRIPT = `
import { marked } from 'https://cdn.jsdelivr.net/npm/marked@12/lib/marked.esm.js'
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs'
mermaid.initialize({ startOnLoad: false, theme: 'dark' })
const rel = decodeURIComponent(location.pathname.replace(/^\\/f\\//, ''))
const el = document.querySelector('.markdown-body')
let last = 0
async function render() {
  const res = await fetch('/raw/' + encodeURIComponent(rel))
  el.innerHTML = marked.parse(await res.text())
  for (const [i, block] of [...el.querySelectorAll('pre code.language-mermaid')].entries()) {
    const div = document.createElement('div')
    try {
      const { svg } = await mermaid.render('mmd' + i + Date.now(), block.textContent)
      div.innerHTML = svg
      block.closest('pre').replaceWith(div)
    } catch {}
  }
}
async function poll() {
  try {
    const { mtime } = await (await fetch('/stat/' + encodeURIComponent(rel))).json()
    if (mtime !== last) { last = mtime; await render() }
  } catch {}
  setTimeout(poll, 1500)
}
poll()
`

const server = createServer(async (req, res) => {
  const url = new URL(req.url, 'http://x')
  const send = (status, type, body) => {
    res.writeHead(status, { 'content-type': type, 'cache-control': 'no-store' })
    res.end(body)
  }
  try {
    if (url.pathname === '/') {
      const files = (await listMarkdown(ROOT)).sort((a, b) => b.mtime - a.mtime)
      const items = files
        .map(
          (f) =>
            `<li><a href="/f/${encodeURIComponent(f.path)}">${esc(f.path)}</a><span class="t">${new Date(f.mtime).toLocaleString()}</span></li>`
        )
        .join('')
      return send(200, 'text/html', PAGE('markdown: ' + ROOT, `<h1>${esc(ROOT)}</h1><ul class="idx">${items}</ul>`))
    }
    if (url.pathname.startsWith('/f/')) {
      const rel = decodeURIComponent(url.pathname.slice(3))
      if (!safePath(rel)) return send(400, 'text/plain', 'bad path')
      return send(200, 'text/html', PAGE(rel, '<p>loading…</p>', VIEW_SCRIPT))
    }
    if (url.pathname.startsWith('/raw/')) {
      const full = safePath(decodeURIComponent(url.pathname.slice(5)))
      if (!full) return send(400, 'text/plain', 'bad path')
      return send(200, 'text/plain; charset=utf-8', await readFile(full, 'utf8'))
    }
    if (url.pathname.startsWith('/stat/')) {
      const full = safePath(decodeURIComponent(url.pathname.slice(6)))
      if (!full) return send(400, 'text/plain', 'bad path')
      const s = await stat(full)
      return send(200, 'application/json', JSON.stringify({ mtime: s.mtimeMs }))
    }
    send(404, 'text/plain', 'not found')
  } catch (err) {
    send(500, 'text/plain', String(err))
  }
})

server.listen(PORT, () => console.log(`md-preview serving ${ROOT} on :${PORT}`))
