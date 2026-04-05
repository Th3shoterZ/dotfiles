local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"

require("lazy").setup({
	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" }
	},
	-- File tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" }
	},
	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" }
	},
	-- Mason (language server installer)
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },
	-- Autocompletion
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{
		"navarasu/onedark.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require('onedark').setup {
				style = 'warmer'
			}
			require('onedark').load()
		end
	},
	{ "stevearc/conform.nvim" },
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			vim.treesitter.language.require_language = nil
			require("nvim-treesitter").setup({
				ensure_installed = { "lua", "typescript", "javascript", "vue", "css", "html", "c_sharp" },
				highlight = {
					enable = true,
				},
			})
		end
	},
	{ "numToStr/Comment.nvim", config = true },
})

require("mason").setup({
	ensure_installed = { "omnisharp", "ts_ls", "lua_ls", "cssls", "vue-language-server", "html", "emmet_ls" },
})

-- Basic settings
vim.opt.number = true         -- line numbers
vim.opt.relativenumber = true -- relative line numbers
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- Setup plugins
require("lualine").setup()
require("nvim-tree").setup({
	update_focused_file = {
		enable = true,
		update_root = false,
	},
})

-- Keybinds
local map = vim.keymap.set
-- move lines
map("n", "<A-j>", ":m .+1<CR>==")
map("n", "<A-k>", ":m .-2<CR>==")
map("v", "<A-j>", ":m '>+1<CR>gv=gv")
map("v", "<A-k>", ":m '<-2<CR>gv=gv")
map("n", "<leader>f", function()
	require("conform").format()
end)

-- exit terminal mode with escape
map("t", "<Esc>", "<C-\\><C-n>")

-- save with ctrl + s
map("n", "<C-s>", ":w<CR>")
map("i", "<C-s>", "<Esc>:w<CR>a")

-- remove file from buffer
map("n", "<leader>x", ":bd<CR>")
-- open buffer menu
map("n", "<C-b>", ":Telescope buffers<CR>")

-- File tree toggle
map("n", "<C-n>", ":NvimTreeToggle<CR>")

-- Telescope
map("n", "<C-p>", ":Telescope find_files<CR>")
map("n", "<C-f>", ":Telescope live_grep<CR>")

-- Buffer navigation
map("n", "<Tab>", ":bn<CR>")
map("n", "<S-Tab>", ":bp<CR>")

-- comment out code
map("n", "<C-/>", "gcc", { remap = true })
map("v", "<C-/>", "gc", { remap = true })

-- LSP Setup
vim.lsp.config('omnisharp', {
	capabilities = require("cmp_nvim_lsp").default_capabilities()
})
-- Get the vue-language-server path from Mason
local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
local vue_plugin_path = mason_packages .. "/vue-language-server/node_modules/@vue/language-server"

-- Configure ts_ls to load the Vue TypeScript plugin
vim.lsp.config('ts_ls', {
	capabilities = capabilities,
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vue_plugin_path,
				languages = { "vue" },
			},
		},
	},
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
})

-- vue_ls itself needs no extra config
vim.lsp.config('vue_ls', { capabilities = capabilities })

-- Enable both
vim.lsp.enable({ "omnisharp", "ts_ls", "lua_ls", "cssls", "vue_ls", "html", "emmet_ls" })
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		typescript = { "prettier" },
		vue = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		cs = { "csharpier" },
		json = { "prettier" },
		jsonc = { "prettier" }
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})

-- Autocompletion
local cmp = require("cmp")
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = { { name = "nvim_lsp" } },
})

-- LSP keybinds
map("n", "gd", vim.lsp.buf.definition)
map("n", "K", vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>ca", vim.lsp.buf.code_action)
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
