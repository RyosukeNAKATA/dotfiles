-- ==============================================================================
-- hlchunk.nvim 設定
-- インデントガイドと現在のコードブロックをハイライトするプラグイン
-- ==============================================================================

-- hlchunk.nvimはtermguicolorsが必要
-- dpp.load_state()より前にinit.luaでも設定しているが、念のためここでも設定
vim.opt.termguicolors = true

require('hlchunk').setup({
    -- chunk: 現在のカーソルがあるコードブロック（チャンク）を線でハイライト
    -- 関数やif文などのスコープを視覚的に把握しやすくする
    chunk = {
        enable = true,
        -- スコープを一色で統一（icebergテーマのpurple）
        style = {
            { fg = "#a093c7" }, -- iceberg purple
        },
    },
    -- indent: インデントレベルをガイド線で表示
    -- コードの階層構造を視覚的に理解しやすくする
    indent = {
        enable = true,
        -- インデントの深さに応じて色を変える（icebergテーマのパレット）
        style = {
            { fg = "#c6c8d1" }, -- レベル1: iceberg pale (最も明るい)
            { fg = "#b4be82" }, -- レベル2: iceberg green
            { fg = "#e2a478" }, -- レベル3: iceberg orange
            { fg = "#89b8c2" }, -- レベル4: iceberg lblue
            { fg = "#a093c7" }, -- レベル5: iceberg purple
            { fg = "#84a0c6" }, -- レベル6: iceberg blue
            { fg = "#e27878" }, -- レベル7: iceberg red
        },
    }
})
