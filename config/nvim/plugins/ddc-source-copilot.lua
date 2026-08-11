-- ==============================================================================
-- ddc-source-copilot 設定
-- GitHub Copilotをddc.vimの補完ソースとして利用するための設定
-- ==============================================================================

-- copilot.vimのデフォルトキーマップを無効化
-- ddc.vimが補完を処理するため、copilot独自のマッピングは不要
vim.g.copilot_no_maps = true

-- ddc.vimにCopilotソースのオプションを追加
-- 注意: 'copilot'ソース自体はddc.vimの設定（ddc.vim）で有効化済み
vim.fn["ddc#custom#patch_global"]("sourceOptions", {
    copilot = {
        -- 補完メニューに表示するマーク
        mark = "[copilot]",
        -- マッチャーは使用しない（Copilotが独自にフィルタリング）
        matchers = {},
        -- 最小文字数なしで補完を開始（Copilotは文脈を見て提案）
        minAutoCompleteLength = 0,
        -- 揮発性（毎回新しい候補を取得）
        -- Copilotは入力に応じてリアルタイムで候補を生成するため必須
        isVolatile = true,
    },
})
