return {
    'nvim-telescope/telescope.nvim',
    version = vim.fn.has('nvim-0.10.4') == 1 and '*' or '0.1.9',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end,
}
