vim.g.mapleader = " "
vim.g.rustaceanvim = {
	server = {
		default_settings = {
			["rust-analyzer"] = {
				checkOnSave = true,
				check = {
					command = "clippy",
				},
			},
		},
	},
}

local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.scrolloff = 8

vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"mrcjkb/rustaceanvim",
		version = "^6",
		lazy = false,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})
		end,
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				lua = { "luacheck" },
				yaml = { "yamllint" },
				toml = { "taplo" },
			}

			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				callback = function()
					lint.try_lint()
				end,
			})

			vim.api.nvim_create_user_command("Lint", function()
				lint.try_lint()
			end, {})

			vim.keymap.set("n", "<leader>l", function()
				lint.try_lint()
			end, { desc = "Run lint" })
		end,
	},
	{
		"stevearc/conform.nvim",
		lazy = false,
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					rust = { "rustfmt" },
					lua = { "stylua" },
					json = { "prettier" },
					yaml = { "prettier" },
					toml = { "taplo" },
				},
				format_on_save = {
					timeout_ms = 3000,
					lsp_format = "fallback",
				},
			})

			vim.api.nvim_create_user_command("Format", function()
				conform.format({
					async = false,
					timeout_ms = 3000,
					lsp_format = "fallback",
				})
			end, {})

			vim.keymap.set("n", "<leader>f", "<cmd>Format<CR>", { desc = "Format buffer" })
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"sainnhe/everforest",
		lazy = false,
		priority = 1000,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				disable_filetype = { "TelescopePrompt" },
			})
		end,
	},
	{
		"saghen/blink.cmp",
		version = "1.*",
		lazy = false,
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "accept", "fallback" },
				["<CR>"] = { "fallback" },
			},

			completion = {
				menu = { auto_show = true },
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = { enabled = true },
			},

			sources = {
				default = { "lsp" },
				per_filetype = {
					rust = { "lsp" },
				},
			},

			signature = { enabled = true },
		},
	},
	{
		"numToStr/Comment.nvim",
		lazy = false,
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		lazy = false,
		opts = {},
	},
	{
		"nvim-telescope/telescope.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions, { desc = "Definitions" })
			vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "References" })
			vim.keymap.set("n", "<leader>fi", builtin.lsp_implementations, { desc = "Implementations" })
			vim.keymap.set("n", "<leader>ft", builtin.lsp_type_definitions, { desc = "Type definitions" })
			vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "Document symbols" })
			vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
		end,
	},
	{
		"folke/trouble.nvim",
		lazy = false,
		opts = {},
		config = function(_, opts)
			require("trouble").setup(opts)

			vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics" })
			vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list" })
			vim.keymap.set("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", { desc = "LSP references" })
		end,
	},
})
vim.cmd.colorscheme("kanagawa")

vim.api.nvim_create_user_command("Theme", function(opts)
	vim.cmd.colorscheme(opts.args)
end, {
	nargs = 1,
	complete = function()
		return {
			"tokyonight",
			"catppuccin",
			"gruvbox",
			"kanagawa",
			"rose-pine",
			"nightfox",
			"everforest",
		}
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf, silent = true }

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	end,
})
