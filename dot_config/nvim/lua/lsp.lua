vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, async = false })
                end,
            })
        end
    end,
})
vim.g.rustfmt_autosave = 1

-- 共通設定（nvim-cmpとの連携）
vim.lsp.config('*', {
})

-- 各LSPサーバーの設定

vim.lsp.config('rust_analyzer', {
    -- Server-specific settings. See `:help lsp-quickstart`
    settings = {
        ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            checkOnSave = true,
            check = { command = "clippy" },
        },
    },
})
vim.lsp.enable('rust_analyzer')

vim.lsp.config('rubocop', {
    settings = {
        rubocop = {
            onSave = true,
        },
    },
})
vim.lsp.enable('rubocop')


vim.lsp.config('sqls', {
    cmd = { 'sqls' },
    filetypes = { 'sql', 'mysql' },
    root_markers = { '.sqls.yaml', '.git' },
    settings = {
        sqls = {
            dialect = "mysql",
        },
    },
})
vim.lsp.enable('sqls')


-- 有効化するLSPサーバー
vim.lsp.enable('lua_ls')

-- LSPの診断が無効な場合にエラーを無視する
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end
