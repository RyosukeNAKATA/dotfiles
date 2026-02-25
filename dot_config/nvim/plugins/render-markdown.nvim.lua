-- ==============================================================================
-- render-markdown.nvim 設定
-- MarkdownファイルをNeovim内でリッチに表示
-- ==============================================================================

require('render-markdown').setup({
    -- プラグインを有効化
    -- 見出し、リスト、コードブロックなどを視覚的に装飾
    enabled = true,
})

-- コードブロックの背景色をコントラストを抑えた色に変更
-- iceberg の CursorLine (#1e2132) に合わせて控えめな背景色を設定
local function set_code_highlights()
    vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = '#1e2132' })
    vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline', { bg = '#1e2132' })
end
set_code_highlights()

-- カラースキーム再適用後も維持する
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = set_code_highlights,
})

-- Markdownファイルを開いた時にTreeSitterのハイライトを有効化
-- render-markdown.nvimはTreeSitterに依存しているため必須
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
        vim.treesitter.start()
    end,
})
