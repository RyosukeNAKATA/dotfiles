-- hlchunk.nvim requires termguicolors
vim.opt.termguicolors = true

require('hlchunk').setup({
    chunk = {
        enable = true,
        -- ...
    },
    indent = {
        enable = true,
        -- ...
    }
})
