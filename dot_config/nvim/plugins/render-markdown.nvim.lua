-- ==============================================================================
-- render-markdown.nvim 設定
-- MarkdownファイルをNeovim内でリッチに表示
-- ==============================================================================

require('render-markdown').setup({
    -- プラグインを有効化
    -- 見出し、リスト、コードブロックなどを視覚的に装飾
    enabled = true,
})

-- Markdownファイルを開いた時にTreeSitterのハイライトを有効化
-- render-markdown.nvimはTreeSitterに依存しているため必須
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
        vim.treesitter.start()
    end,
})
