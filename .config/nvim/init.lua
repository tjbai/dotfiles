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
vim.opt.autoread = true

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
      vim.g.VM_maps = {
        ["Find Under"] = "<D-d>",
        ["Find Subword Under"] = "<D-d>",
        ["Add Cursor Down"] = "<C-j>",
        ["Add Cursor Up"] = "<C-k>",
      }
      vim.g.VM_leader = "\\"
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
        ensure_installed = { "jinja", "jinja_inline", "javascript", "tsx", "typescript" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- jinja syntax (works with markdown, html, etc.)
  { "HiPhish/jinja.vim" },

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

  -- comments (with jsx support)
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

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

  -- winbar
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      vim.opt.laststatus = 0
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = "",
          section_separators = "",
        },
        sections = {},
        inactive_sections = {},
        winbar = {
          lualine_c = {
            { function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") end },
            {
              'filename',
              path = 1,
              file_status = true,
              newfile_status = true,
              symbols = { modified = '[+]', readonly = '[-]', unnamed = '[No Name]', newfile = '[New]' },
            }
          },
        },
        inactive_winbar = {
          lualine_c = {
            { function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") end },
            {
              'filename',
              path = 1,
              file_status = true,
              newfile_status = true,
              symbols = { modified = '[+]', readonly = '[-]', unnamed = '[No Name]', newfile = '[New]' },
            }
          },
        },
      })
    end,
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

require("kanagawa").setup({
  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "none",
        },
      },
    },
  },
})

-- theme persistence
local theme_file = vim.fn.stdpath("data") .. "/theme.txt"

local function save_theme(name)
  local f = io.open(theme_file, "w")
  if f then f:write(name) f:close() end
end

local function load_theme()
  local f = io.open(theme_file, "r")
  if f then
    local name = f:read("*l")
    f:close()
    if name and name ~= "" then return name end
  end
  return "kanagawa"
end

vim.cmd.colorscheme(load_theme())

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function() save_theme(vim.g.colors_name) end,
})

-- lsp (native neovim 0.11)
vim.lsp.enable('basedpyright')
vim.lsp.enable('lua_ls')
vim.lsp.enable('tsgo', {
  settings = {
    typescript = {
      preferences = {
        includePackageJsonAutoImports = "auto",
      },
      tsserver = {
        maxTsServerMemory = 8192, -- fuck me i'm getting wrecked
      },
    },
  },
})

-- diagnostics
vim.diagnostic.config({
  virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
  underline = { severity = { min = vim.diagnostic.severity.ERROR } },
  signs = { severity = { min = vim.diagnostic.severity.ERROR } },
  severity_sort = true,
})

-- auto reload files changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
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

map("n", "<D-b>", ":Neotree toggle reveal<CR>", s)
map("n", "<leader>e", ":Neotree toggle reveal<CR>", s)

map("n", "<D-B>", ":GitBlameToggle<CR>", s)
map("n", "<leader>gb", ":GitBlameToggle<CR>", s)

map("n", "<D-/>", function() require("Comment.api").toggle.linewise.current() end, s)
map("v", "<D-/>", "<Esc><Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", s)

local toggle_numbers = function()
  vim.opt.number = not vim.opt.number:get()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end
map("n", "<D-'>", toggle_numbers, s)
map("n", "<leader>n", toggle_numbers, s)

map("n", "<D-\\>", ":vsplit<CR>", s)
map("n", "<D-S-\\>", ":split<CR>", s)
map("n", "<leader>v", ":vsplit<CR>", s)
map("n", "<leader>-", ":split<CR>", s)

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
map("n", "<leader>1", function() go_to_split(1) end, s)
map("n", "<leader>2", function() go_to_split(2) end, s)
map("n", "<leader>3", function() go_to_split(3) end, s)
map("n", "<leader>4", function() go_to_split(4) end, s)
map("n", "<leader>5", function() go_to_split(5) end, s)

local new_tab = function()
  vim.ui.input({ prompt = "Directory: ", default = "~/", completion = "dir" }, function(dir)
    if dir and dir ~= "" then
      vim.cmd("tabnew")
      vim.cmd("tcd " .. vim.fn.expand(dir))
      require("alpha").start()
    end
  end)
end
map("n", "<D-t>", new_tab, s)
map("n", "<leader>tn", new_tab, s)
map("n", "<D-}>", ":tabnext<CR>", s)
map("n", "<D-{>", ":tabprev<CR>", s)
map("n", "<leader>]", ":tabnext<CR>", s)
map("n", "<leader>[", ":tabprev<CR>", s)
map("n", "<D-S-w>", ":tabclose<CR>", s)
map("n", "<leader>tc", ":tabclose<CR>", s)

map("n", "<D-p>", ":Telescope find_files<CR>", s)
map("n", "<D-S-p>", ":Telescope commands<CR>", s)
map("n", "<D-S-f>", ":Telescope live_grep<CR>", s)
map("n", "<D-S-t>", ":Telescope colorscheme enable_preview=true<CR>", s)
map("n", "<D-S-h>", function() require("spectre").open() end, s)
map("n", "<leader>f", ":Telescope find_files<CR>", s)
map("n", "<leader><leader>", ":Telescope find_files<CR>", s)
map("n", "<leader>:", ":Telescope commands<CR>", s)
map("n", "<leader>/", ":Telescope live_grep<CR>", s)
map("n", "<leader>th", ":Telescope colorscheme enable_preview=true<CR>", s)
map("n", "<leader>sr", function() require("spectre").open() end, s)

local close_buf = function()
  local buf = vim.api.nvim_get_current_buf()
  local wins = vim.fn.win_findbuf(buf)
  if #wins > 1 then vim.cmd("close") else vim.cmd("bd") end
end
map("n", "<D-w>", close_buf, s)
map("n", "<leader>x", close_buf, s)

map({ "n", "i", "v" }, "<D-s>", "<Cmd>w<CR>", s)
map("n", "<leader>w", ":w<CR>", s)

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

local hover_or_diag = function()
  local has_diag = #vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 }) > 0
  if has_diag then vim.diagnostic.open_float() else vim.lsp.buf.hover() end
end
map("n", "<D-k>", hover_or_diag, s)
map("n", "K", hover_or_diag, s)

local format_buf = function() require("conform").format({ lsp_fallback = true }) end
map({ "n", "v" }, "<D-I>", format_buf, s)
map({ "n", "v" }, "<leader>lf", format_buf, s)

map("n", "zR", require("ufo").openAllFolds)
map("n", "zM", require("ufo").closeAllFolds)

map("n", "]q", ":cnext<CR>", s)
map("n", "[q", ":cprev<CR>", s)
map("n", "]Q", ":clast<CR>", s)
map("n", "[Q", ":cfirst<CR>", s)

map("i", "<D-BS>", "<C-u>")
map("i", "<A-BS>", "<C-w>")
map("i", "<D-Left>", "<Home>")
map("i", "<D-Right>", "<End>")
map("i", "<A-Left>", "<C-Left>")
map("i", "<A-Right>", "<C-Right>")

map({ "n", "v" }, "<D-c>", '"+y')
map({ "n", "v" }, "<D-v>", '"+p')
map("i", "<D-v>", '<C-r>+')
map("c", "<D-v>", '<C-r>+')
map("n", "<D-a>", "ggVG")
map("n", "<leader>a", "ggVG")
map({ "n", "v" }, "<leader>y", '"+y')
map({ "n", "v" }, "<leader>p", '"+p')

if vim.g.neovide then
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.3
  vim.g.neovide_text_gamma = 0.8
  vim.g.neovide_text_contrast = 0.1
end
