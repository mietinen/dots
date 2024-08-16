local custom_attach = function(client, bufnr)
    local opts = {buffer = bufnr, silent = true}
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    client.server_capabilities.semanticTokensProvider = nil
end

return {
    'neovim/nvim-lspconfig',
    config = function()
        local lsp = require('lspconfig')
        local lsp_setup = function(server, config)
            local cmd = config.cmd or lsp[server].document_config.default_config.cmd or {''}
            config.on_attach = config.on_attach or custom_attach
            if vim.fn.executable(cmd[1]) ~= 0 then
                lsp[server].setup(config)
            end
        end
        lsp_setup('gopls', {})
        lsp_setup('rust_analyzer', {})
        lsp_setup('bashls', {})
        lsp_setup('pyright', {})
        lsp_setup('lua_ls', {
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = {
                        globals = { 'vim', 'awesome', 'client', 'screen', 'root' },
                        disable = { 'lowercase-global' },
                    },
                    workspace = { library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false },
                },
            },
        })
    end,
}
