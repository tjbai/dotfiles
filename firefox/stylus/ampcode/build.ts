// generates one stylus .user.css per palette for ampcode.com.
// run: bun build.ts   (writes ./<name>.user.css + stylus-import.json)
//
// ampcode.com's palette is entirely css custom properties on :root,
// so a theme is just one override block. dark palettes mirror
// sentinel/ui/src/index.css; light ones are each scheme's own light
// variant, or a palette built for reading on paper (flexoki, modus,
// github), picked for body-text contrast >= 7:1 where the scheme has it.

interface Palette {
	label: string
	scheme: "light" | "dark"
	bg: string // page background: transcript, sidebar
	bg1: string // raised surface: composer, cards, popover, editor
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
		scheme: 'dark',
		bg: '#282828', bg1: '#32302f', bg2: '#3c3836', bg3: '#504945',
		fg: '#ebdbb2', fgMuted: '#a89984', fgDim: '#928374',
		red: '#fb4934', green: '#b8bb26', yellow: '#fabd2f', blue: '#83a598',
		magenta: '#d3869b', cyan: '#8ec07c', orange: '#fe8019',
	},
	catppuccin: {
		label: 'Catppuccin Mocha',
		scheme: 'dark',
		bg: '#1e1e2e', bg1: '#262637', bg2: '#313244', bg3: '#45475a',
		fg: '#cdd6f4', fgMuted: '#9399b2', fgDim: '#6c7086',
		red: '#f38ba8', green: '#a6e3a1', yellow: '#f9e2af', blue: '#89b4fa',
		magenta: '#cba6f7', cyan: '#89dceb', orange: '#fab387',
	},
	kanagawa: {
		label: 'Kanagawa Wave',
		scheme: 'dark',
		bg: '#1f1f28', bg1: '#26262f', bg2: '#2a2a37', bg3: '#363646',
		fg: '#dcd7ba', fgMuted: '#938a80', fgDim: '#727169',
		red: '#ff5d62', green: '#98bb6c', yellow: '#e6c384', blue: '#7e9cd8',
		magenta: '#957fb8', cyan: '#7fb4ca', orange: '#ffa066',
	},
	everforest: {
		label: 'Everforest Dark',
		scheme: 'dark',
		bg: '#2d353b', bg1: '#333c43', bg2: '#3d484d', bg3: '#475258',
		fg: '#d3c6aa', fgMuted: '#859289', fgDim: '#7a8478',
		red: '#e67e80', green: '#a7c080', yellow: '#dbbc7f', blue: '#7fbbb3',
		magenta: '#d699b6', cyan: '#83c092', orange: '#e69875',
	},
	nordfox: {
		label: 'Nordfox',
		scheme: 'dark',
		bg: '#2e3440', bg1: '#353c4a', bg2: '#3b4252', bg3: '#434c5e',
		fg: '#cdcecf', fgMuted: '#7e8a9e', fgDim: '#60728a',
		red: '#bf616a', green: '#a3be8c', yellow: '#ebcb8b', blue: '#81a1c1',
		magenta: '#b48ead', cyan: '#88c0d0', orange: '#d08770',
	},
	rosepine: {
		label: 'Rosé Pine',
		scheme: 'dark',
		bg: '#191724', bg1: '#1f1d2e', bg2: '#26233a', bg3: '#403d52',
		fg: '#e0def4', fgMuted: '#908caa', fgDim: '#6e6a86',
		red: '#eb6f92', green: '#56949f', yellow: '#f6c177', blue: '#9ccfd8',
		magenta: '#c4a7e7', cyan: '#9ccfd8', orange: '#ebbcba',
	},

	// light. bg1 follows each scheme's own convention for a raised surface
	// (usually one step darker than the page, like stock amp's --card).
	// body-text contrast (fg on bg) in the label comment.

	// stephango.com/flexoki: inky, warm paper. 18:1
	flexoki: {
		label: 'Flexoki Light',
		scheme: 'light',
		bg: '#fffcf0', bg1: '#f2f0e5', bg2: '#e6e4d9', bg3: '#cecdc3',
		fg: '#100f0f', fgMuted: '#6f6e69', fgDim: '#878580',
		red: '#af3029', green: '#66800b', yellow: '#ad8301', blue: '#205ea6',
		magenta: '#5e409d', cyan: '#24837b', orange: '#bc5215',
	},
	// protesilaos modus-operandi: wcag aaa everywhere, pure white. 21:1
	modus: {
		label: 'Modus Operandi',
		scheme: 'light',
		bg: '#ffffff', bg1: '#f2f2f2', bg2: '#e0e0e0', bg3: '#c4c4c4',
		fg: '#000000', fgMuted: '#595959', fgDim: '#595959',
		red: '#a60000', green: '#006800', yellow: '#6f5500', blue: '#0031a9',
		magenta: '#721045', cyan: '#005e8b', orange: '#972500',
	},
	// primer light: neutral, cool grey. 15:1
	github: {
		label: 'GitHub Light',
		scheme: 'light',
		bg: '#ffffff', bg1: '#f6f8fa', bg2: '#eaeef2', bg3: '#d0d7de',
		fg: '#1f2328', fgMuted: '#656d76', fgDim: '#6e7781',
		red: '#cf222e', green: '#1a7f37', yellow: '#9a6700', blue: '#0969da',
		magenta: '#8250df', cyan: '#1b7c83', orange: '#bc4c00',
	},
	// gruvbox light hard. 10:1
	gruvboxlight: {
		label: 'Gruvbox Light',
		scheme: 'light',
		bg: '#f9f5d7', bg1: '#f2e5bc', bg2: '#ebdbb2', bg3: '#d5c4a1',
		fg: '#3c3836', fgMuted: '#665c54', fgDim: '#928374',
		red: '#9d0006', green: '#79740e', yellow: '#b57614', blue: '#076678',
		magenta: '#8f3f71', cyan: '#427b58', orange: '#af3a03',
	},
	// catppuccin latte. 7.5:1
	latte: {
		label: 'Catppuccin Latte',
		scheme: 'light',
		bg: '#eff1f5', bg1: '#e6e9ef', bg2: '#ccd0da', bg3: '#bcc0cc',
		fg: '#4c4f69', fgMuted: '#6c6f85', fgDim: '#7c7f93',
		red: '#d20f39', green: '#40a02b', yellow: '#df8e1d', blue: '#1e66f5',
		magenta: '#8839ef', cyan: '#179299', orange: '#fe640b',
	},
	// kanagawa lotus. 7.6:1
	lotus: {
		label: 'Kanagawa Lotus',
		scheme: 'light',
		bg: '#f2ecbc', bg1: '#e5ddb0', bg2: '#dcd5ac', bg3: '#d5cea3',
		fg: '#43436c', fgMuted: '#545464', fgDim: '#8a8980',
		red: '#c84053', green: '#6f894e', yellow: '#77713f', blue: '#4d699b',
		magenta: '#624c83', cyan: '#597b75', orange: '#cc6d00',
	},
	// rosé pine dawn. surface is lighter than base, so bg1 goes up. 6.4:1
	dawn: {
		label: 'Rosé Pine Dawn',
		scheme: 'light',
		bg: '#faf4ed', bg1: '#fffaf3', bg2: '#f2e9e1', bg3: '#dfdad9',
		fg: '#575279', fgMuted: '#797593', fgDim: '#9893a5',
		red: '#b4637a', green: '#56949f', yellow: '#ea9d34', blue: '#286983',
		magenta: '#907aa9', cyan: '#56949f', orange: '#d7827e',
	},
	// nightfox dayfox. 11:1
	dayfox: {
		label: 'Dayfox',
		scheme: 'light',
		bg: '#f6f2ee', bg1: '#e4dcd4', bg2: '#dbd1dd', bg3: '#d3c7bb',
		fg: '#3d2b5a', fgMuted: '#643f61', fgDim: '#837a72',
		red: '#a5222f', green: '#396847', yellow: '#ac5402', blue: '#2848a9',
		magenta: '#6e33ce', cyan: '#287980', orange: '#955f61',
	},
}

function css(name: string, p: Palette): string {
	// ampcode.com defines its palette on :root with light-dark() values and
	// re-scopes some vars per region via [data-amp-content-theme]. built-in
	// themes use :root[data-amp-theme=...], so every override is !important
	// to win on specificity regardless of what the user has picked in-app.
	const light = p.scheme === "light"
	// diff rows: light accents are saturated, so a lighter tint reads the same.
	const diffMix = light ? 12 : 18
	// ansi black paints text (context-analysis "other" bar, terminal output),
	// so on paper it has to be ink, not the border grey.
	const black = light ? p.fgMuted : p.bg3
	const vars: [string, string][] = [
		// --background is amp's raised layer: the composer form, floating pills,
		// toolbars (`bg-background`). the page, transcript and sidebar paint from
		// --app-surface-background. stock dark keeps them 3% apart; use bg1 so
		// the composer lifts off the page instead of going flat.
		["--background", `${p.bg1}`],
		// inline <head> style paints html/body and the main surface from these,
		// not from --background. both light and dark so color-scheme can't leak.
		["--amp-shell-light-background-color", `${p.bg}`],
		["--amp-shell-dark-background-color", `${p.bg}`],
		["--amp-surface-light-background-color", `${p.bg}`],
		["--amp-surface-dark-background-color", `${p.bg}`],
		// declared on .app-shell itself, so the selector below includes .app-shell.
		["--app-surface-background", `${p.bg}`],
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
		["--diff-addition-background", `color-mix(in oklab, ${p.green} ${diffMix}%, ${p.bg})`],
		["--diff-removal-background", `color-mix(in oklab, ${p.red} ${diffMix}%, ${p.bg})`],
		["--diff-addition-foreground", `${p.green}`],
		["--diff-removal-foreground", `${p.red}`],
		["--diff-meta-foreground", `${p.yellow}`],
		["--hljs-function", `${p.blue}`],
		["--hljs-keyword", `${p.magenta}`],
		["--hljs-class", `${p.yellow}`],
		["--hljs-string", `${p.green}`],
		["--hljs-comment", `${p.fgDim}`],
		["--hljs-number", `${p.orange}`],
		["--terminal-black", black],
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
@version      1.2.0
@description  ${p.label} palette for ampcode.com.
==/UserStyle== */
@-moz-document domain("ampcode.com") {
  :root, [data-amp-content-theme], .app-shell {
    color-scheme: ${p.scheme} !important;
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
