return {
    'tpope/vim-surround',
    'tpope/vim-commentary',
    'junegunn/vim-peekaboo',
    'sbdchd/neoformat',
    { 'dhruvasagar/vim-table-mode', init = function() vim.g.table_mode_corner = '|' end },
    { 'nvim-lualine/lualine.nvim', config = true },
}
