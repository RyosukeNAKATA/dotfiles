require("conform").setup({
    formatters_by_ft = {
        rust = { "rustfmt" },
        ruby = { "rubocop" },
        sql = { "sql_formatter" },
        mysql = { "sql_formatter" },
        json = { "biome" },
    },
    format_on_save = function(bufnr)
        -- フォーマッタが設定されている場合のみ実行
        local formatters = require("conform").list_formatters(bufnr)
        if #formatters > 0 then
            return {
                timeout_ms = 2000,
                lsp_fallback = false,
            }
        end
        return nil -- フォーマッタがなければスキップ
    end,
})
