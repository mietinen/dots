return {
	{
		'hrsh7th/nvim-cmp',
		config = function()
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('snippy').expand_snippet(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'snippy' },
                    { name = 'buffer' },
                })
            })
		end,
	},

    { 'dcampos/cmp-snippy', dependencies = 'dcampos/nvim-snippy' },
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
}
