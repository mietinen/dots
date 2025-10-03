vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspStuff', { clear = true }),
    callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '[d', function() vim.diagnostic.jump({count= -1,float = true}) end, opts)
        vim.keymap.set('n', ']d', function() vim.diagnostic.jump({count= 1,float = true}) end, opts)
        client.server_capabilities.semanticTokensProvider = nil
    end
})

vim.diagnostic.config({
    virtual_text = true,
    float = {
        border = "rounded",
        source = true
    },
})

local lsp_setup = function(server, config)
    vim.lsp.config(server, config)
    if vim.fn.executable(vim.lsp.config[server].cmd[1]) ~= 0 then
        vim.lsp.enable(server)
    end
end

return {
    'neovim/nvim-lspconfig',
    config = function()
        lsp_setup('gopls', {})
        lsp_setup('rust_analyzer', {})
        lsp_setup('bashls', {})
        lsp_setup('pyright', {})
        lsp_setup('lua_ls', {
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = {
                        disable = { 'lowercase-global' },
                    },
                    workspace = {
                        -- library = vim.api.nvim_get_runtime_file('', true),
                        library = { vim.env.VIMRUNTIME },
                        checkThirdParty = false
                    },
                },
            },
        })
    end,
}
