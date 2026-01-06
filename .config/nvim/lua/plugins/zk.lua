-- Only load for Neovim 0.11+
if vim.fn.has('nvim-0.11') ~= 1 then
    return {}
end

return {
    'zk-org/zk-nvim',
    dependencies = 'nvim-telescope/telescope.nvim',
    config = function()
        require('zk').setup({picker = 'telescope'})
        vim.keymap.set('n', '<leader>zn', '<Cmd>ZkNew { title = vim.fn.input("Title: ") }<CR>', {silent = true})
        vim.keymap.set('n', '<leader>zf', '<Cmd>ZkNotes { sort = { "modified" } }<CR>', {silent = true})
    end,
}
