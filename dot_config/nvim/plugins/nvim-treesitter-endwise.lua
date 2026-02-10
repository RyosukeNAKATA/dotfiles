-- ==============================================================================
-- nvim-treesitter-endwise 設定
-- treesitterを利用してend/endifなどを自動挿入
-- ==============================================================================

require('nvim-treesitter.configs').setup({
    endwise = {
        enable = true,
    },
})
