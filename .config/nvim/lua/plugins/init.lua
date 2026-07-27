return {
	{
		'andweeb/presence.nvim',
		lazy = false
	},
	{
		'VonHeikemen/lsp-zero.nvim',
		dependencies = {
			'neovim/nvim-lspconfig',
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',

			'hrsh7th/nvim-cmp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lua',

			'L3M0N4D3/LuaSnip',
			'rafamadriz/friendly-snippets'
		}
	},
	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		config = function()
			require('nvim-autopairs').setup {
				check_ts = true,
				map_cr = false
			}
		end
	},
	{
		'lewis6991/gitsigns.nvim',
		config = true
	},
	{
		'utilyre/barbecue.nvim',
		config = true,
		dependencies = {
			'SmiteshP/nvim-navic',
			'nvim-tree/nvim-web-devicons'
		}
	},
}

