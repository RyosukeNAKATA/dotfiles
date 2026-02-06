-- ==============================================================================
-- nvim-treesitter 設定
-- TreeSitterによる高精度なシンタックスハイライトを提供
-- ==============================================================================

-- filetypeからTree-sitterのパーサー名へのマッピング
-- filetypeとパーサー名が異なる場合のみ定義（同名なら不要）
local ft_to_parser = {
    vimdoc = 'vimdoc',
}

--- filetypeに対応するTree-sitterパーサー名を返す
--- @param ft string filetype
--- @return string パーサー名
local function get_parser_name(ft)
    return ft_to_parser[ft] or ft
end

--- 指定パーサーがインストール済みかどうかを判定する
--- @param lang string パーサー名
--- @return boolean
local function is_parser_installed(lang)
    local ok = pcall(vim.treesitter.language.inspect, lang)
    return ok
end

-- ファイルを開いた時にパーサーが未インストールなら自動的にインストールし、
-- ハイライトと折りたたみを有効化する
vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft == '' then
            return
        end

        local lang = get_parser_name(ft)

        if not is_parser_installed(lang) then
            -- パーサーが未インストールならインストールを試みる
            -- インストール完了後にハイライトと折りたたみを有効化
            vim.cmd('TSInstall ' .. lang)
        end

        -- パーサーが利用可能ならハイライトと折りたたみを有効化
        if is_parser_installed(lang) then
            vim.treesitter.start()
            vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo[0][0].foldmethod = 'expr'
        end
    end,
})
