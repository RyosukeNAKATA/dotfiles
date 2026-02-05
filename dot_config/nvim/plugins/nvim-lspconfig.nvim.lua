-- ==============================================================================
-- nvim-lspconfig 設定
-- LSPクライアントのキーマップとautocmd設定
-- ==============================================================================
-- NOTE:
-- Neovim 0.11+ では require('lspconfig') の代わりに
-- vim.lsp.config() / vim.lsp.enable() を使用する
-- LSPサーバーの設定は lua/lsp.lua で行っているため、
-- このファイルではキーマップとautocmdのみ設定

-- ==============================================================================
-- グローバルキーマッピング（診断機能）
-- ==============================================================================
-- Space+e: カーソル位置の診断をフロートウィンドウで表示
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
-- [d: 前の診断に移動
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
-- ]d: 次の診断に移動
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- Space+q: 診断をロケーションリストに追加
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- ==============================================================================
-- LspAttach autocmd
-- LSPサーバーがバッファにアタッチした時にキーマップを設定
-- ==============================================================================
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Ctrl-x Ctrl-o でLSP補完をトリガー可能にする
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- バッファローカルのキーマッピング
        local opts = { buffer = ev.buf }

        -- 定義・参照ジャンプ
        -- gD: 宣言へジャンプ
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        -- gd: 定義へジャンプ
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        -- K: ホバー情報表示（関数のドキュメント等）
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        -- gi: 実装へジャンプ
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        -- Ctrl-k: シグネチャヘルプ（関数の引数情報）
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

        -- ワークスペース管理
        -- Space+wa: ワークスペースフォルダを追加
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        -- Space+wr: ワークスペースフォルダを削除
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        -- Space+wl: ワークスペースフォルダ一覧を表示
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)

        -- リファクタリング
        -- Space+D: 型定義へジャンプ
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        -- Space+rn: シンボルの名前変更
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        -- Space+ca: コードアクション（クイックフィックス等）
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        -- gr: 参照一覧を表示
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

        -- Space+f: 非同期フォーマット
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
