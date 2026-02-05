-- Install desired parsers
require('nvim-treesitter').install { 'rust', 'markdown', 'ruby', 'toml', 'yaml', 'lua', 'vim', 'vimdoc', 'typescript', 'javascript', 'html', 'css', 'json' }

-- Enable treesitter-based highlighting for common filetypes
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'rust', 'markdown', 'ruby', 'toml', 'yaml', 'lua', 'vim', 'typescript', 'javascript', 'html', 'css', 'json' },
    callback = function()
        vim.treesitter.start()
    end,
})

-- Enable treesitter-based folding
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'rust', 'markdown', 'ruby', 'toml', 'yaml', 'lua', 'vim', 'typescript', 'javascript', 'html', 'css', 'json' },
    callback = function()
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
    end,
})
