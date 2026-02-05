-- ==============================================================================
-- nvim-treesitter 設定
-- TreeSitterによる高精度なシンタックスハイライトを提供
-- ==============================================================================

-- 使用するパーサーをインストール
-- 主に使用する言語のパーサーを事前にインストールしておく
-- vim/vimdocはNeovimの設定ファイル用、その他は開発で使用する言語
require('nvim-treesitter').install {
    'rust',
    'markdown',
    'ruby',
    'toml',
    'yaml',
    'lua',
    'vim',
    'vimdoc',
    'typescript',
    'javascript',
    'html',
    'css',
    'json'
}

-- TreeSitterベースのハイライトを有効化
-- FileTypeイベントで対象ファイルタイプが開かれた時に自動的にハイライトを開始
-- 従来の正規表現ベースよりも正確で高速なハイライトが可能
vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'rust', 'markdown', 'ruby', 'toml', 'yaml', 'lua', 'vim',
        'typescript', 'javascript', 'html', 'css', 'json'
    },
    callback = function()
        vim.treesitter.start()
    end,
})

-- TreeSitterベースの折りたたみを有効化
-- コードの構造に基づいた折りたたみが可能になる
-- 例: 関数単位、クラス単位での折りたたみ
vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'rust', 'markdown', 'ruby', 'toml', 'yaml', 'lua', 'vim',
        'typescript', 'javascript', 'html', 'css', 'json'
    },
    callback = function()
        -- 折りたたみ式をTreeSitterの関数に設定
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- 折りたたみ方式を式評価に設定
        vim.wo[0][0].foldmethod = 'expr'
    end,
})
