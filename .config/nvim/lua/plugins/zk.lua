return {
	{
		'zk-org/zk-nvim',
		dependencies = 'nvim-telescope/telescope.nvim',
		config = function()
            require('zk').setup({picker = 'telescope'})
            vim.keymap.set('n', '<leader>zn', '<Cmd>ZkNew { title = vim.fn.input("Title: ") }<CR>', {silent = true})
            vim.keymap.set('n', '<leader>zf', '<Cmd>ZkNotes { sort = { "modified" } }<CR>', {silent = true})
		end,
	},
}
