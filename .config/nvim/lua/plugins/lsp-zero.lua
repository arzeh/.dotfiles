return {
	'VonHeikemen/lsp-zero.nvim',
	dependencies = {
		'neovim/nvim-lspconfig',
		{
			'williamboman/mason.nvim',
			config = true
		},
		'williamboman/mason-lspconfig.nvim',

		'hrsh7th/nvim-cmp',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
		'saadparwaiz1/cmp_luasnip',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-nvim-lua',

		'L3MON4D3/LuaSnip',
		'rafamadriz/friendly-snippets',

		'roobert/tailwindcss-colorizer-cmp.nvim'
	},
	config = function()
		local lsp = require('lsp-zero')
		require('lspconfig').gleam.setup({})

		lsp.on_attach(function(_, bufnr)
			local opts = { buffer = bufnr, remap = false }

			local function set(map, callback, mode)
				mode = mode or 'n'
				vim.keymap.set(mode, map, callback, opts)
			end

			set("gd", function() vim.lsp.buf.definition() end)
			set("K", function() vim.lsp.buf.hover() end)
			set("<leader>vws", function() vim.lsp.buf.workspace_symbol() end)
			set("<leader>vd", function() vim.diagnostic.open_float() end)
			set("[d", function() vim.diagnostic.goto_next() end)
			set("]d", function() vim.diagnostic.goto_prev() end)
			set("<leader>vca", function() vim.lsp.buf.code_action() end)
			set("<leader>vrr", function() vim.lsp.buf.references() end)
			set("<leader>vrn", function() vim.lsp.buf.rename() end)
			set("<C-h>", function() vim.lsp.buf.signature_help() end, "i")
			set("<C-y>", function() vim.lsp.buf.hover() end, "i")
		end)

		require('mason').setup({})
		require('mason-lspconfig').setup({
			ensure_installed = { 'ts_ls', 'lua_ls', 'rust_analyzer' },
			handlers = {
				lsp.default_setup,
				lua_ls = function()
					local lua_opts = lsp.nvim_lua_ls()
					require('lspconfig').lua_ls.setup(lua_opts)
				end,
				tailwindcss = function()
					require('lspconfig').tailwindcss.setup({
						filetypes = { 'html' },
					})
				end
			}
		})

		local cmp = require('cmp')
		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		local cmp_mappings = {
			['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
			['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
			['<C-y>'] = cmp.mapping.confirm({ select = true }),
			['<C-Space>'] = cmp.mapping.complete()
		}

		local tailwind = require('tailwindcss-colorizer-cmp').formatter
		cmp.setup({
			formatting = {
				format = function(entry, vim_item)
					vim_item = lsp.cmp_format().format(entry, vim_item)
					vim_item = tailwind(entry, vim_item)
					return vim_item
				end
			},
			mapping = cmp.mapping.preset.insert(cmp_mappings),
			sources = {
				{ name = 'path' },
				{ name = 'nvim_lsp' },
				{ name = 'nvim_lua' },
				{ name = 'supermaven' }
			}
		})
	end
}

