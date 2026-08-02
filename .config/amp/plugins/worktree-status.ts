import type { PluginAPI, ThreadID } from '@ampcode/plugin'
import { spawn } from 'node:child_process'
import { existsSync } from 'node:fs'
import { basename } from 'node:path'

interface Worktree {
	path: string
	branch: string
}

const REFRESH_INTERVAL_MS = 15_000

export default function (amp: PluginAPI) {
	const root = amp.system.workspaceRoot
		? amp.helpers.filePathFromURI(amp.system.workspaceRoot)
		: null

	let worktrees: Worktree[] = []
	let lastRefresh = 0
	const activeByThread = new Map<ThreadID, string>()

	async function refreshWorktrees(force = false): Promise<void> {
		if (!root) return
		const now = Date.now()
		if (!force && now - lastRefresh < REFRESH_INTERVAL_MS) return
		lastRefresh = now
		const result = await amp.$`git -C ${root} worktree list --porcelain`
		if (result.exitCode !== 0) return
		const parsed: Worktree[] = []
		let path: string | null = null
		for (const line of result.stdout.split('\n')) {
			if (line.startsWith('worktree ')) {
				path = line.slice('worktree '.length)
			} else if (line.startsWith('branch ') && path) {
				parsed.push({
					path,
					branch: line.slice('branch '.length).replace(/^refs\/heads\//, ''),
				})
				path = null
			}
		}
		worktrees = parsed.filter(
			(wt) =>
				!wt.path.startsWith('/private/var/folders/') &&
				!wt.path.startsWith('/var/folders/') &&
				!wt.path.startsWith('/tmp/') &&
				existsSync(wt.path),
		)
	}

	function matchWorktree(candidate: string): Worktree | null {
		const path =
			candidate.startsWith('/') || !root ? candidate : `${root}/${candidate}`
		let best: Worktree | null = null
		for (const wt of worktrees) {
			if (path === wt.path || path.startsWith(wt.path + '/')) {
				if (!best || wt.path.length > best.path.length) best = wt
			}
		}
		return best
	}

	function worktreeName(wt: Worktree): string {
		return wt.path === root ? `${basename(wt.path)} (root)` : basename(wt.path)
	}

	void refreshWorktrees(true)

	amp.on('tool.call', async (event) => {
		try {
			await refreshWorktrees()
			const candidates: string[] = []
			const shell = amp.helpers.shellCommandFromToolCall(event)
			if (shell?.dir) candidates.push(shell.dir)
			const files = amp.helpers.filesModifiedByToolCall(event)
			if (files) {
				for (const file of files) {
					candidates.push(amp.helpers.filePathFromURI(file))
				}
			}
			for (const candidate of candidates) {
				const wt = matchWorktree(candidate)
				if (wt) {
					activeByThread.set(event.thread.id, wt.path)
					break
				}
			}
		} catch (error) {
			amp.logger.log('worktree-status tool.call error', error)
		}
		return { action: 'allow' }
	})

	interface CommandUI {
		ui: {
			notify(message: string): Promise<void>
			select(options: {
				title: string
				message?: string
				options: string[]
			}): Promise<string | undefined>
		}
		thread?: { id: ThreadID }
	}

	async function resolveWorktree(ctx: CommandUI): Promise<Worktree | undefined> {
		await refreshWorktrees(true)
		if (worktrees.length === 0) {
			await ctx.ui.notify('No git worktrees found.')
			return undefined
		}
		const threadID = ctx.thread?.id
		const tracked = threadID ? activeByThread.get(threadID) : undefined
		if (tracked) {
			const wt = worktrees.find((w) => w.path === tracked)
			if (wt) return wt
		}
		const labels = worktrees.map((wt) => `${worktreeName(wt)}  [${wt.branch}]`)
		const choice = await ctx.ui.select({
			title: 'Select worktree',
			message: 'No worktree activity tracked in this thread yet.',
			options: labels,
		})
		if (choice === undefined) return undefined
		return worktrees[labels.indexOf(choice)]
	}

	function copyToClipboard(value: string): Promise<boolean> {
		return new Promise((resolve) => {
			const proc = spawn('pbcopy')
			proc.on('error', () => resolve(false))
			proc.on('close', (code) => resolve(code === 0))
			proc.stdin.end(value)
		})
	}

	amp.registerCommand(
		'copy-active-branch',
		{
			title: 'Copy Active Branch',
			category: 'worktree',
			description: 'Copy the branch of the worktree this thread is working in.',
		},
		async (ctx) => {
			const wt = await resolveWorktree(ctx)
			if (!wt) return
			const result = await amp.$`git -C ${wt.path} branch --show-current`
			const branch = result.stdout.trim() || wt.branch
			if (await copyToClipboard(branch)) {
				await ctx.ui.notify(`Copied branch: ${branch}`)
			} else {
				await ctx.ui.notify(`Failed to copy. Branch: ${branch}`)
			}
		},
	)

	amp.registerCommand(
		'copy-active-worktree-path',
		{
			title: 'Copy Active Worktree Path',
			category: 'worktree',
			description: 'Copy the path of the worktree this thread is working in.',
		},
		async (ctx) => {
			const wt = await resolveWorktree(ctx)
			if (!wt) return
			if (await copyToClipboard(wt.path)) {
				await ctx.ui.notify(`Copied path: ${wt.path}`)
			} else {
				await ctx.ui.notify(`Failed to copy. Path: ${wt.path}`)
			}
		},
	)
}
