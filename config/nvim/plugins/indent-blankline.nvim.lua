-- ==============================================================================
-- indent-blankline.nvim (ibl) 設定
-- 高速・軽量なインデントガイドプラグイン
-- ==============================================================================

local highlight = {
    "RainbowPurple",
    "RainbowBlue",
    "RainbowCyan",
    "RainbowGreen",
    "RainbowOrange",
    "RainbowRed",
}

local hooks = require("ibl.hooks")

-- Iceberg カラーパレットのハイライト定義フック
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowPurple", { fg = "#a093c7" }) -- レベル1: iceberg purple
    vim.api.nvim_set_hl(0, "RainbowBlue",   { fg = "#84a0c6" }) -- レベル2: iceberg blue
    vim.api.nvim_set_hl(0, "RainbowCyan",   { fg = "#89b8c2" }) -- レベル3: iceberg lblue
    vim.api.nvim_set_hl(0, "RainbowGreen",  { fg = "#b4be82" }) -- レベル4: iceberg green
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#e2a478" }) -- レベル5: iceberg orange
    vim.api.nvim_set_hl(0, "RainbowRed",    { fg = "#e27878" }) -- レベル6: iceberg red
end)

require("ibl").setup({
    indent = {
        highlight = highlight,
        char = "│",
    },
    scope = {
        enabled = true,
        show_start = false,
        show_end = false,
    },
})
