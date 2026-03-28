return {
	'catppuccin/nvim',
	-- 'darianmorat/gruvdark.nvim',
	-- 'Kaikacy/Lemons.nvim',
	lazy = false,
	priority = 1000,
	config = function ()
		--[[
		require('catppuccin').setup {
			integrations = {
				cmp = true,
				gitsigns = true,
				harpoon = true,
				mason = true,
				native_lsp = { enabled = true },
				noice = true,
				telescope = true,
				treesitter = true,
				treesitter_context =true,
			}
		}

		--]]
		vim.cmd.colorscheme('catppuccin-mocha')
		-- vim.cmd.colorscheme('gruvdark')
		vim.cmd('highlight SignColumn guibg=NONE')
	end
}
