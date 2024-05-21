-- -----------------------------------------------------------------------------
-- Settings
-- -----------------------------------------------------------------------------
vim.cmd.syntax('on')
vim.opt.encoding = 'utf-8'
vim.opt.mouse = 'niv'
vim.opt.clipboard:append 'unnamedplus'
vim.opt.scrolloff = 5
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
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
vim.keymap.set('n', '<leader>r', ':!<C-r>=expand("%:p")<CR> ')
vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set('v', '<leader>s', [["hy:%s/<C-r>=escape(@h,'/\:')<CR>/<C-r>=escape(@h,'/\:')<CR>/gI<left><left><left>]])
vim.keymap.set('v', '<leader>p', '"_dP')
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- -----------------------------------------------------------------------------
-- Autocmd
-- -----------------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('FTStuff', { clear = true }),
    callback = function(args)
        local m = args.match
        if m == 'markdown' then
            vim.cmd.setlocal('wrap linebreak spell')
            vim.b.current_syntax = nil
            vim.cmd.syntax('include @markdownTomlTop syntax/toml.vim')
            vim.cmd.syntax('region markdownTomlHead start=/\\%^+++$/ end=/^+++$/ keepend contains=@markdownTomlTop')
        elseif m == 'text' then vim.cmd.setlocal('wrap linebreak spell')
        elseif m == 'php' then vim.cmd.setlocal('commentstring=//%s')
        elseif m == 'xdefaults' then vim.cmd.setlocal('commentstring=!%s')
        elseif m == 'htmldjango' then vim.cmd.setlocal('commentstring={#%s#}')
        end
        vim.cmd.set('formatoptions-=o foldmethod=manual')
    end
})

-- -----------------------------------------------------------------------------
-- Fallback colorscheme
-- -----------------------------------------------------------------------------
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
vim.cmd.highlight('Normal guibg=NONE ctermbg=NONE')

-- -----------------------------------------------------------------------------
-- lazy.nvim (lua/plugins)
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
    change_detection = { notify = false }
})
