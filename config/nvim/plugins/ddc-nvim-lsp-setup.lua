-- ==============================================================================
-- ddc-source-lsp 設定
-- ddc.vimとLSPを連携させるための設定
-- ==============================================================================

-- 全LSPサーバーにddc.vim用のcapabilitiesを設定
-- これによりLSPサーバーがddc.vimに適した補完情報を返すようになる
vim.lsp.config('*', {
    capabilities = require("ddc_source_lsp").make_client_capabilities(),
})
