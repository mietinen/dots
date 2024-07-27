return {
    {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup()
            require("nvim-highlight-colors").turnOff()
            vim.keymap.set('n', '<leader>h', '<Cmd>:HighlightColors Toggle<CR>', {silent = true})
        end
    },
}
