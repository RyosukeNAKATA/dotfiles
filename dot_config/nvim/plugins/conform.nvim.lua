-- ==============================================================================
-- conform.nvim 設定
-- 軽量で強力なコードフォーマッター
-- ==============================================================================

require("conform").setup({
    -- ファイルタイプごとに使用するフォーマッターを指定
    formatters_by_ft = {
        -- Rust: rast-grepでフォーマット
        rust = { "ast-grep" },
        -- Go:
        go = { "ast-grep" },
        -- Ruby: rubocop（リンター兼フォーマッター）でフォーマット
        ruby = { "rubocop" },
        -- SQL: sql_formatterでフォーマット
        sql = { "sql_formatter" },
        mysql = { "sql_formatter" },
        -- JSON: biome（旧Rome）でフォーマット
        json = { "biome" },
        -- TOML: tombiでフォーマット
        toml = { "tombi" },
    },

    -- 保存時に自動フォーマットを実行
    format_on_save = function(bufnr)
        -- フォーマッタが設定されているファイルタイプのみ実行
        -- 設定されていない場合はフォーマットをスキップ
        local formatters = require("conform").list_formatters(bufnr)
        if #formatters > 0 then
            return {
                -- タイムアウト: 2秒（大きいファイルでも十分な時間）
                timeout_ms = 2000,
                -- LSPフォールバック無効
                -- conform.nvimで指定したフォーマッターのみ使用
                lsp_fallback = false,
            }
        end
        -- フォーマッターがなければスキップ
        return nil
    end,
})
