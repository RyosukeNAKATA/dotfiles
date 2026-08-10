-- ==============================================================================
-- mason.nvim 設定
-- LSPサーバー、フォーマッター、リンターのパッケージマネージャー
-- ==============================================================================

-- Neovim環境のPATH先頭に mise の shims を追加して mise の Ruby/Node等を最優先で参照
local mise_shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(mise_shims) == 1 then
    vim.env.PATH = mise_shims .. ":" .. vim.env.PATH
end

-- デフォルト設定で初期化
-- :Mason コマンドでGUIを開き、パッケージをインストール/管理可能
-- インストールされたツールは自動的にPATHに追加される
require("mason").setup()
