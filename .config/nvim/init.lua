-- -----------------------------------------------------------------------------
-- Plugins
-- -----------------------------------------------------------------------------
local packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    packer_bootstrap = true
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_path }
    vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'tpope/vim-surround'
    use 'tpope/vim-commentary'
    use 'junegunn/vim-peekaboo'
    use 'itchyny/lightline.vim'
    use 'sbdchd/neoformat'
    use { 'gruvbox-community/gruvbox', config = 'applycolorscheme("gruvbox")' }
    use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim' }
    use { 'mickael-menu/zk-nvim', requires = 'nvim-telescope/telescope.nvim' }
    use {
        'neovim/nvim-lspconfig',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        { 'dcampos/cmp-snippy', requires = 'dcampos/nvim-snippy' }
    }
    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- -----------------------------------------------------------------------------
-- Settings
-- -----------------------------------------------------------------------------
vim.cmd.syntax('on')
vim.opt.go = 'a'
vim.opt.encoding = 'utf-8'
vim.opt.mouse = 'niv'
vim.opt.clipboard:append 'unnamedplus'
vim.opt.scrolloff = 5
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.sidescroll = 1
vim.opt.scrolloff = 7
vim.opt.spelllang = 'en,nb'
vim.opt.colorcolumn = '80,110'
vim.opt.listchars = 'tab:| ,extends:>,precedes:<,trail:+,nbsp:~'
vim.opt.laststatus = 2
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.background = 'dark'
vim.g.mapleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.markdown_fenced_languages = {
    'rust', 'go', 'python',
    'lua', 'vim', 'viml=vim',
    'sh', 'bash=sh', 'zsh', 'ps1',
    'html', 'css', 'php',
    'yaml'
}

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------
vim.keymap.set('n', '<leader>e', ':Lexplore<CR>', {silent = true})
vim.keymap.set('n', '<leader><CR>', ':source $MYVIMRC <bar> echo "Reloaded ".fnamemodify($MYVIMRC, ":t")<CR>', {silent = true})
vim.keymap.set('n', '<leader>w', [[:%s/\s\+$//e<CR>]], {silent = true})
vim.keymap.set('n', '<leader>l', ':set list!<CR>', {silent = true})
vim.keymap.set('n', '<leader>R', ':!<C-r>=expand("%:p")<CR> ')
vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set('v', '<leader>s', [["hy:%s/<C-r>=escape(@h,'/\:')<CR>/<C-r>=escape(@h,'/\:')<CR>/gI<left><left><left>]])
vim.keymap.set('v', '<leader>p', '"_dP')

-- -----------------------------------------------------------------------------
-- Colors
-- -----------------------------------------------------------------------------
applycolorscheme = function(color)
    color = color or ''
    if vim.fn.globpath(vim.o.runtimepath, 'colors/'..color..'.vim')
    .. vim.fn.globpath(vim.o.runtimepath, 'colors/'..color..'.lua') == '' then
        vim.cmd.highlight('clear SignColumn')
        vim.cmd.highlight('LineNR ctermfg=Grey')
        vim.cmd.highlight('ColorColumn ctermbg=Black')
        vim.cmd.highlight('NonText ctermfg=DarkGrey')
        vim.cmd.highlight('Pmenu ctermbg=Black ctermfg=Grey')
        vim.cmd.highlight('PmenuSel ctermbg=Cyan ctermfg=Black')
        vim.cmd.highlight('SpellBad ctermbg=NONE ctermfg=NONE cterm=underline')
        vim.cmd.highlight('SpellCap ctermbg=NONE ctermfg=NONE cterm=underline')
        vim.cmd.highlight('CursorLine ctermbg=Black cterm=NONE')
        vim.cmd.highlight('CursorLineNR ctermbg=Black cterm=NONE')
        vim.cmd.highlight('link markdownCode PreProc')
    else
        vim.g.gruvbox_contrast_dark = 'hard'
        vim.g.gruvbox_sign_column = 'none'
        vim.cmd.colorscheme(color)
    end
    vim.g.lightline = { colorscheme = vim.g.colors_name or 'default' }
    vim.cmd.highlight('Normal guibg=NONE ctermbg=NONE')
end
applycolorscheme()

-- -----------------------------------------------------------------------------
-- Autocmd
-- -----------------------------------------------------------------------------
local ft = vim.api.nvim_create_augroup('FTStuff', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    group = ft,
    callback = function(args)
        local m = args.match
        if m == 'markdown' then vim.cmd.setlocal('wrap linebreak spell')
        elseif m == 'text' then vim.cmd.setlocal('wrap linebreak spell')
        elseif m == 'php' then vim.cmd.setlocal('commentstring=//%s')
        elseif m == 'xdefaults' then vim.cmd.setlocal('commentstring=!%s')
        elseif m == 'htmldjango' then vim.cmd.setlocal('commentstring={#%s#}')
        end
        vim.cmd.set('formatoptions-=o foldmethod=manual')
    end
})

-- -----------------------------------------------------------------------------
-- nvim-lspconfig
-- -----------------------------------------------------------------------------
local lsp_ok, lsp = pcall(require, 'lspconfig')
if lsp_ok then
    local on_attach = function(client, bufnr)
        local opts = {buffer = bufnr, silent = true}
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        client.server_capabilities.semanticTokensProvider = nil
    end
    local lsp_setup = function(server, config)
        local cmd = config.cmd or lsp[server].document_config.default_config.cmd or {''}
        config.on_attach = config.on_attach or on_attach
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
end

-- -----------------------------------------------------------------------------
-- nvim-cmp
-- -----------------------------------------------------------------------------
local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then
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
end

-- -----------------------------------------------------------------------------
-- nvim-snippy
-- -----------------------------------------------------------------------------
local snippy_ok, snippy = pcall(require, 'snippy')
if snippy_ok then
    snippy.setup({
        mappings = {
            is = {
                ['<Tab>'] = 'expand_or_advance',
                ['<S-Tab>'] = 'previous',
            },
            nx = {
                ['<leader>x'] = 'cut_text',
            },
        },
    })
end

-- -----------------------------------------------------------------------------
-- telescope.nvim
-- -----------------------------------------------------------------------------
local telescope_ok, telescope = pcall(require, 'telescope.builtin')
if telescope_ok then
    vim.keymap.set('n', '<leader>ff', telescope.find_files, {})
    vim.keymap.set('n', '<leader>fg', telescope.live_grep, {})
    vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
    vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})
end

-- -----------------------------------------------------------------------------
-- zk-nvim
-- -----------------------------------------------------------------------------
local zk_ok, zk = pcall(require, 'zk')
if zk_ok then
    zk.setup({picker = 'telescope'})
    vim.keymap.set('n', '<leader>zn', '<Cmd>ZkNew { title = vim.fn.input("Title: ") }<CR>', {silent = true})
    vim.keymap.set('n', '<leader>zf', '<Cmd>ZkNotes { sort = { "modified" } }<CR>', {silent = true})
end
