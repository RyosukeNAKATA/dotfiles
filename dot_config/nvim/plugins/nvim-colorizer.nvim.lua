-- ==============================================================================
-- nvim-colorizer.lua 設定
-- カラーコード（#FF0000等）を実際の色でハイライト
-- ==============================================================================

-- デフォルト設定で有効化
-- CSS、HTML、Luaなどのファイルでカラーコードを視覚的に確認可能
if vim.iter then
    vim.tbl_flatten = function(t)
        return vim.iter(t):flatten(math.huge):totable()
    end
end

require 'colorizer'.setup()
