-- Set display options
vim.opt.termguicolors = true
vim.opt.listchars = { tab = "»-", nbsp = "¬", extends = "»", precedes = "«", trail = "•", eol = "↲" }
vim.opt.list = true

-- Define highlight groups using ibl.hooks (recommended approach)
local highlight = {
    "IblRed",
    "IblYellow",
    "IblGreen",
    "IblCyan",
    "IblBlue",
    "IblMagenta",
}

local hooks = require("ibl.hooks")

-- Create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "IblRed", { fg = "#e27878" })
    vim.api.nvim_set_hl(0, "IblYellow", { fg = "#e2a478" })
    vim.api.nvim_set_hl(0, "IblGreen", { fg = "#b4be82" })
    vim.api.nvim_set_hl(0, "IblCyan", { fg = "#89b8c2" })
    vim.api.nvim_set_hl(0, "IblBlue", { fg = "#84a0c6" })
    vim.api.nvim_set_hl(0, "IblMagenta", { fg = "#a093c7" })
end)

-- indent-blankline.nvim v3 configuration
require("ibl").setup({
    indent = {
        char = "│",
        highlight = highlight,
    },
    scope = {
        enabled = true,
    },
})
