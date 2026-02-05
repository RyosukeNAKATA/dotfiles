-- Set display options
vim.opt.termguicolors = true
vim.opt.listchars = { tab = "»-", nbsp = "¬", extends = "»", precedes = "«", trail = "•", eol = "↲" }
vim.opt.list = true

-- Define highlight groups for indent-blankline (must be defined before ibl.setup)
local highlight_groups = {
    IblRed = { fg = "#e27878", nocombine = true },
    IblYellow = { fg = "#e2a478", nocombine = true },
    IblGreen = { fg = "#b4be82", nocombine = true },
    IblCyan = { fg = "#89b8c2", nocombine = true },
    IblBlue = { fg = "#84a0c6", nocombine = true },
    IblMagenta = { fg = "#a093c7", nocombine = true },
}

for name, opts in pairs(highlight_groups) do
    vim.api.nvim_set_hl(0, name, opts)
end

-- Re-apply highlights on ColorScheme change
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        for name, opts in pairs(highlight_groups) do
            vim.api.nvim_set_hl(0, name, opts)
        end
    end,
})

-- indent-blankline.nvim v3 configuration
require("ibl").setup({
    indent = {
        char = "│",
        highlight = { "IblRed", "IblYellow", "IblGreen", "IblCyan", "IblBlue", "IblMagenta" },
    },
    scope = {
        enabled = true,
    },
})