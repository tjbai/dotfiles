-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "

-- mason bin path (for LSPs)
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- options
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 250
vim.opt.wrap = false
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- plugins
require("lazy").setup({
  -- file tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    opts = {
      filesystem = { follow_current_file = { enabled = true }, hijack_netrw_behavior = "disabled" },
      window = { width = 35 },
    },
  },

  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
    },
  },

  -- git blame
  { "f-person/git-blame.nvim", opts = { enabled = false } },

  -- multi-cursor
  {
    "mg979/vim-visual-multi",
    init = function()
      vim.g.VM_maps = { ["Find Under"] = "<D-d>", ["Find Subword Under"] = "<D-d>" }
      vim.g.VM_theme = "iceblue"
    end,
  },

  -- lsp
  { "williamboman/mason.nvim", opts = {} },
  { "neovim/nvim-lspconfig" },

  -- formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        markdown = { "prettierd" },
      },

    },
  },

  -- autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = { { name = "nvim_lsp" } },
      })
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("ufo").setup({
        provider_selector = function() return { "treesitter", "indent" } end,
      })
    end,
  },

  -- search/replace across files
  { "nvim-pack/nvim-spectre", dependencies = { "nvim-lua/plenary.nvim" } },

  -- autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- comments
  { "numToStr/Comment.nvim", opts = {} },

  -- git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "-" },
        },
      })
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = { theme = "catppuccin", component_separators = "", section_separators = "" },
      sections = {
        lualine_a = {}, lualine_b = {}, lualine_c = { "filename" },
        lualine_x = { "location" }, lualine_y = {}, lualine_z = {},
      },
      inactive_sections = { lualine_c = { "filename" }, lualine_x = {} },
    },
  },

  -- themes
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "folke/tokyonight.nvim" },
  { "rose-pine/neovim", name = "rose-pine" },
  { "rebelot/kanagawa.nvim" },
  { "sainnhe/gruvbox-material" },
  { "sainnhe/everforest" },
  { "EdenEast/nightfox.nvim" },
  { "navarasu/onedark.nvim" },
  { "Mofiqul/dracula.nvim" },
  { "bluz71/vim-nightfly-colors", name = "nightfly" },
  { "bluz71/vim-moonfly-colors", name = "moonfly" },

  -- start screen
  {
    "goolord/alpha-nvim",
    lazy = false,
    priority = 900,
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- stats
      local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
      local files = vim.fn.system("ls -1 | wc -l"):gsub("%s+", "")
      
      local header = {
        "",
        "  󰉋  " .. cwd,
        "",
        "  󰈔  " .. files .. " files",
        "",
        "  󰘬  " .. (branch ~= "" and branch or "no git"),
        "",
      }

      dashboard.section.header.val = header
      dashboard.section.buttons.val = {}
      dashboard.opts.layout = {
        { type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.35) }) },
        dashboard.section.header,
      }
      alpha.setup(dashboard.opts)
    end,
  },
})

vim.cmd.colorscheme("catppuccin-mocha")

-- lsp (native neovim 0.11)
vim.lsp.enable('basedpyright')
vim.lsp.enable('lua_ls')
vim.lsp.enable('tsgo')

-- diagnostics
vim.diagnostic.config({
  virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
  underline = { severity = { min = vim.diagnostic.severity.ERROR } },
  signs = { severity = { min = vim.diagnostic.severity.ERROR } },
  severity_sort = true,
})

-- auto clear search highlight
vim.on_key(function(char)
  if vim.fn.mode() == "n" then
    local keys = { "<CR>", "n", "N", "*", "#", "?", "/", "z" }
    local new_hlsearch = vim.tbl_contains(keys, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
  end
end, vim.api.nvim_create_namespace("auto_hlsearch"))

-- open alpha when launching with directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.cmd("bd")
      require("alpha").start()
    end
  end,
})

local map = vim.keymap.set
local s = { silent = true }

-- file tree
map("n", "<D-b>", ":Neotree toggle reveal<CR>", s)

-- git blame
map("n", "<D-B>", ":GitBlameToggle<CR>", s)

-- comments
map("n", "<D-/>", function() require("Comment.api").toggle.linewise.current() end, s)
map("v", "<D-/>", "<Esc><Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", s)

-- line numbers
map("n", "<D-'>", function()
  vim.opt.number = not vim.opt.number:get()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, s)

-- splits
map("n", "<D-\\>", ":vsplit<CR>", s)
map("n", "<D-S-\\>", ":split<CR>", s)

local function go_to_split(n)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  while #wins < n do vim.cmd("vsplit") wins = vim.api.nvim_tabpage_list_wins(0) end
  vim.cmd(n .. "wincmd w")
end
map("n", "<D-1>", function() go_to_split(1) end, s)
map("n", "<D-2>", function() go_to_split(2) end, s)
map("n", "<D-3>", function() go_to_split(3) end, s)
map("n", "<D-4>", function() go_to_split(4) end, s)
map("n", "<D-5>", function() go_to_split(5) end, s)
map("n", "<D-{>", "<C-w>h", s)
map("n", "<D-}>", "<C-w>l", s)

-- telescope
map("n", "<D-p>", ":Telescope find_files<CR>", s)
map("n", "<D-S-p>", ":Telescope commands<CR>", s)
map("n", "<D-S-f>", ":Telescope live_grep<CR>", s)
map("n", "<D-S-t>", ":Telescope colorscheme enable_preview=true<CR>", s)
map("n", "<D-S-h>", function() require("spectre").open() end, s)

-- close buffer/split
map("n", "<D-w>", function()
  local buf = vim.api.nvim_get_current_buf()
  local wins = vim.fn.win_findbuf(buf)
  if #wins > 1 then vim.cmd("close") else vim.cmd("bd") end
end, s)

-- lsp
map("n", "gd", function()
  local cur_file = vim.api.nvim_buf_get_name(0)
  vim.lsp.buf.definition({
    on_list = function(opts)
      if #opts.items == 0 then return end
      local item = opts.items[1]
      if vim.fn.fnamemodify(item.filename, ":p") ~= cur_file then vim.cmd("vsplit") end
      vim.cmd("edit " .. item.filename)
      vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
    end
  })
end, s)
map("n", "<D-k>", function()
  local has_diag = #vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 }) > 0
  if has_diag then vim.diagnostic.open_float() else vim.lsp.buf.hover() end
end, s)
map({ "n", "v" }, "<D-I>", function() require("conform").format({ lsp_fallback = true }) end, s)

-- folding
map("n", "zR", require("ufo").openAllFolds)
map("n", "zM", require("ufo").closeAllFolds)

-- natural text editing
map("i", "<D-BS>", "<C-u>")
map("i", "<A-BS>", "<C-w>")
map("i", "<D-Left>", "<Home>")
map("i", "<D-Right>", "<End>")
map("i", "<A-Left>", "<C-Left>")
map("i", "<A-Right>", "<C-Right>")

-- neovide
if vim.g.neovide then
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.3
  vim.g.neovide_text_gamma = 0.0
  vim.g.neovide_text_contrast = 0.5
  map({ "n", "v" }, "<D-c>", '"+y')
  map({ "n", "v" }, "<D-v>", '"+p')
  map("i", "<D-v>", '<C-r>+')
  map("c", "<D-v>", '<C-r>+')
  map("n", "<D-a>", "ggVG")
end
