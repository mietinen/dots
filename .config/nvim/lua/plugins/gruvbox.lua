return {
    'gruvbox-community/gruvbox',
    config = function()
        vim.g.gruvbox_contrast_dark = 'hard'
        vim.g.gruvbox_sign_column = 'none'
        vim.cmd.colorscheme('gruvbox')
        vim.cmd.highlight('Normal guibg=NONE ctermbg=NONE')
    end,
}
