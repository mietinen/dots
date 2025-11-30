return {
    'tpope/vim-surround',
    'junegunn/vim-peekaboo',
    { 'dhruvasagar/vim-table-mode', init = function() vim.g.table_mode_corner = '|' end },
    { 'nvim-lualine/lualine.nvim', config = true },
}
