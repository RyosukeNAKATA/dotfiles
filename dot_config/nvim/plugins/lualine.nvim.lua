-- ==============================================================================
-- lualine.nvim 設定
-- 高速でカスタマイズ可能なステータスライン
-- ==============================================================================

require('lualine').setup {
    options = {
        -- アイコンを有効化（nvim-web-deviconsが必要）
        icons_enabled = true,
        -- icebergカラースキームに合わせたテーマ
        theme = 'iceberg_dark',
        -- セクション間の区切り文字
        -- 左右に三角形のセパレーターを使用
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        -- 特定のファイルタイプでは無効化しない（全てで表示）
        disabled_filetypes = {},
        -- 常に中央で分割（左右のバランスを保つ）
        always_divide_middle = true,
        -- グローバルステータスライン無効
        -- 各ウィンドウに個別のステータスラインを表示
        globalstatus = false,
    },
    -- アクティブウィンドウのステータスライン構成
    sections = {
        -- 左端: 現在のモード（NORMAL, INSERT等）
        lualine_a = {'mode'},
        -- 左2: Gitブランチ、差分情報、診断情報
        lualine_b = {'branch', 'diff', 'diagnostics'},
        -- 中央左: ファイル名
        lualine_c = {'filename'},
        -- 中央右: エンコーディング、ファイルフォーマット、ファイルタイプ
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        -- 右2: ファイル内の進捗率
        lualine_y = {'progress'},
        -- 右端: カーソル位置（行:列）
        lualine_z = {'location'}
    },
    -- 非アクティブウィンドウのステータスライン構成
    -- 最小限の情報のみ表示
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        -- ファイル名のみ
        lualine_c = {'filename'},
        -- カーソル位置のみ
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    -- タブライン（画面上部）は使用しない
    tabline = {},
    -- 拡張機能（特定のプラグイン用の表示）は使用しない
    extensions = {}
}
