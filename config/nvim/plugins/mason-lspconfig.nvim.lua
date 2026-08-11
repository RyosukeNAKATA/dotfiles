-- ==============================================================================
-- mason-lspconfig.nvim 設定
-- masonとlspconfigを連携させるブリッジ
-- ==============================================================================

require("mason-lspconfig").setup({
    -- 自動インストールするLSPサーバーのリスト
    -- Neovim起動時に未インストールの場合は自動でインストール
    ensure_installed = {
        -- Lua: Neovim設定ファイル用
        "lua_ls",
        -- Rust: Rustプログラミング用
        "rust_analyzer",
        -- Ruby: Rubocopをランゲージサーバーとして使用
        "rubocop",
    },
})
