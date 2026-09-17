// generates one stylus .user.css per palette for ampcode.com.
// run: bun build.ts   (writes ./<name>.user.css + stylus-import.json)
//
// ampcode.com's palette is entirely css custom properties on :root,
// so a theme is just one override block. palettes mirror
// sentinel/ui/src/index.css.

interface Palette {
	label: string
	bg: string // page background
	bg1: string // raised surface: cards, popover, editor
	bg2: string // muted fill, selection, hover
	bg3: string // border
	fg: string
	fgMuted: string
	fgDim: string // comments, bright-black
	red: string
	green: string
	yellow: string
	blue: string
	magenta: string
	cyan: string
	orange: string
}

const palettes: Record<string, Palette> = {
	gruvbox: {
		label: 'Gruvbox Dark',
		bg: '#282828', bg1: '#32302f', bg2: '#3c3836', bg3: '#504945',
		fg: '#ebdbb2', fgMuted: '#a89984', fgDim: '#928374',
		red: '#fb4934', green: '#b8bb26', yellow: '#fabd2f', blue: '#83a598',
		magenta: '#d3869b', cyan: '#8ec07c', orange: '#fe8019',
	},
	catppuccin: {
		label: 'Catppuccin Mocha',
		bg: '#1e1e2e', bg1: '#262637', bg2: '#313244', bg3: '#45475a',
		fg: '#cdd6f4', fgMuted: '#9399b2', fgDim: '#6c7086',
		red: '#f38ba8', green: '#a6e3a1', yellow: '#f9e2af', blue: '#89b4fa',
		magenta: '#cba6f7', cyan: '#89dceb', orange: '#fab387',
	},
	kanagawa: {
		label: 'Kanagawa Wave',
		bg: '#1f1f28', bg1: '#26262f', bg2: '#2a2a37', bg3: '#363646',
		fg: '#dcd7ba', fgMuted: '#938a80', fgDim: '#727169',
		red: '#ff5d62', green: '#98bb6c', yellow: '#e6c384', blue: '#7e9cd8',
		magenta: '#957fb8', cyan: '#7fb4ca', orange: '#ffa066',
	},
	everforest: {
		label: 'Everforest Dark',
		bg: '#2d353b', bg1: '#333c43', bg2: '#3d484d', bg3: '#475258',
		fg: '#d3c6aa', fgMuted: '#859289', fgDim: '#7a8478',
		red: '#e67e80', green: '#a7c080', yellow: '#dbbc7f', blue: '#7fbbb3',
		magenta: '#d699b6', cyan: '#83c092', orange: '#e69875',
	},
	nordfox: {
		label: 'Nordfox',
		bg: '#2e3440', bg1: '#353c4a', bg2: '#3b4252', bg3: '#434c5e',
		fg: '#cdcecf', fgMuted: '#7e8a9e', fgDim: '#60728a',
		red: '#bf616a', green: '#a3be8c', yellow: '#ebcb8b', blue: '#81a1c1',
		magenta: '#b48ead', cyan: '#88c0d0', orange: '#d08770',
	},
	rosepine: {
		label: 'Rosé Pine',
		bg: '#191724', bg1: '#1f1d2e', bg2: '#26233a', bg3: '#403d52',
		fg: '#e0def4', fgMuted: '#908caa', fgDim: '#6e6a86',
		red: '#eb6f92', green: '#56949f', yellow: '#f6c177', blue: '#9ccfd8',
		magenta: '#c4a7e7', cyan: '#9ccfd8', orange: '#ebbcba',
	},
}

function css(name: string, p: Palette): string {
	// ampcode.com defines its palette on :root with light-dark() values and
	// re-scopes some vars per region via [data-amp-content-theme]. built-in
	// themes use :root[data-amp-theme=...], so every override is !important
	// to win on specificity regardless of what the user has picked in-app.
	const vars: [string, string][] = [
		["--background", `${p.bg}`],
		["--foreground", `${p.fg}`],
		["--border", `${p.bg3}`],
		["--muted", `${p.bg2}`],
		["--muted-foreground", `${p.fgMuted}`],
		["--card", `${p.bg1}`],
		["--popover", `${p.bg1}`],
		["--input-background", `${p.bg1}`],
		["--input-border", `${p.bg3}`],
		["--primary", `${p.fg}`],
		["--primary-hover", `${p.fgMuted}`],
		["--primary-foreground", `${p.bg}`],
		["--secondary", `${p.bg2}`],
		["--secondary-hover", `${p.bg3}`],
		["--secondary-foreground", `${p.fg}`],
		["--accent", `${p.bg2}`],
		["--accent-foreground", `${p.fg}`],
		["--ring", `${p.blue}`],
		["--link", `${p.blue}`],
		["--brand", `${p.orange}`],
		["--mention", `${p.magenta}`],
		["--success", `${p.green}`],
		["--warning", `${p.yellow}`],
		["--warning-foreground", `${p.bg}`],
		["--warning-border", `${p.yellow}`],
		["--destructive", `${p.red}`],
		["--destructive-background", `${p.red}`],
		["--destructive-foreground", `${p.bg}`],
		["--selection-background", `color-mix(in oklab, ${p.blue} 30%, transparent)`],
		["--transcript-selection-background", `color-mix(in oklab, ${p.green} 30%, transparent)`],
		["--linked-passage-background", `color-mix(in oklab, ${p.magenta} 25%, transparent)`],
		["--editor-background", `${p.bg1}`],
		["--editor-foreground", `${p.fg}`],
		["--diff-addition-background", `color-mix(in oklab, ${p.green} 18%, ${p.bg})`],
		["--diff-removal-background", `color-mix(in oklab, ${p.red} 18%, ${p.bg})`],
		["--diff-addition-foreground", `${p.green}`],
		["--diff-removal-foreground", `${p.red}`],
		["--diff-meta-foreground", `${p.yellow}`],
		["--hljs-function", `${p.blue}`],
		["--hljs-keyword", `${p.magenta}`],
		["--hljs-class", `${p.yellow}`],
		["--hljs-string", `${p.green}`],
		["--hljs-comment", `${p.fgDim}`],
		["--hljs-number", `${p.orange}`],
		["--terminal-black", `${p.bg3}`],
		["--terminal-red", `${p.red}`],
		["--terminal-green", `${p.green}`],
		["--terminal-yellow", `${p.yellow}`],
		["--terminal-blue", `${p.blue}`],
		["--terminal-magenta", `${p.magenta}`],
		["--terminal-cyan", `${p.cyan}`],
		["--terminal-white", `${p.fgMuted}`],
		["--terminal-bright-black", `${p.fgDim}`],
		["--terminal-bright-red", `${p.red}`],
		["--terminal-bright-green", `${p.green}`],
		["--terminal-bright-yellow", `${p.yellow}`],
		["--terminal-bright-blue", `${p.blue}`],
		["--terminal-bright-magenta", `${p.magenta}`],
		["--terminal-bright-cyan", `${p.cyan}`],
		["--terminal-bright-white", `${p.fg}`],
	]
	const decls = vars.map(([k, v]) => `    ${k}: ${v} !important;`).join("\n")
	return `/* ==UserStyle==
@name         ampcode ${p.label}
@namespace    tjbai/amp-web-themes
@version      1.1.0
@description  ${p.label} palette for ampcode.com, ported from sentinel.
==/UserStyle== */
@-moz-document domain("ampcode.com") {
  :root, [data-amp-content-theme] {
    color-scheme: dark !important;
${decls}
  }
}
`
}

// stylus manage -> import styles reads this. sections carry the bare rule
// block; the @-moz-document wrapper is expressed as the domains field.
function section(body: string): string {
	const open = body.indexOf("{", body.indexOf("@-moz-document"))
	return body.slice(open + 1, body.lastIndexOf("}")).trim()
}

const styles = []
for (const [name, p] of Object.entries(palettes)) {
	const body = css(name, p)
	await Bun.write(new URL(`./${name}.user.css`, import.meta.url), body)
	console.log(`wrote ${name}.user.css`)
	styles.push({
		name: `ampcode ${p.label}`,
		enabled: name === "kanagawa",
		sections: [{ code: section(body), domains: ["ampcode.com"] }],
	})
}
await Bun.write(new URL("./stylus-import.json", import.meta.url), JSON.stringify(styles, null, "\t") + "\n")
console.log("wrote stylus-import.json")
