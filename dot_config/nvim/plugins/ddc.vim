" ==============================================================================
" ddc.vim 設定
" Deno製の自動補完フレームワーク
" ==============================================================================

" ------------------------------------------------------------------------------
" 基本設定
" ------------------------------------------------------------------------------
" UIとしてpum.vimを使用（ポップアップメニュー表示）
call ddc#custom#patch_global(
      \  'ui',
      \  'pum',
      \  )

" 補完ソースの優先順位を設定
" 上から順に優先度が高い
" - copilot: GitHub Copilotによる AI補完
" - lsp: Language Serverからの補完
" - around: カーソル周辺の単語からの補完
" - file: ファイルパス補完
" - cmdline_history: コマンドライン履歴からの補完
call ddc#custom#patch_global('sources', [
      \  'copilot',
      \  'lsp',
      \  'around',
      \  'file',
      \  'cmdline_history',
      \  ])

" ------------------------------------------------------------------------------
" ソースオプション設定
" ------------------------------------------------------------------------------
call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_head'],
      \   'sorters': ['sorter_rank'],
      \   'converters': ['converter_remove_overlap'],
      \ },
      \ 'lsp': {
      \   'mark': '[LSP]',
      \   'forceCompletionPattern': '\.\w*|:\w*|->\w*'
      \ },
      \ 'around': {
      \   'mark': '[around]'
      \ },
      \ 'file': {
      \   'mark': '[file]',
      \   'isVolatile': v:true, 
      \   'forceCompletionPattern': '\S/\S*'
      \ },
      \ 'cmdline_history': {
      \   'mark': '[history]',
      \ },
      \})

" ------------------------------------------------------------------------------
" LSPソースのパラメータ設定
" ------------------------------------------------------------------------------
call ddc#custom#patch_global('sourceParams', #{
      \   lsp: #{
      \     snippetEngine: denops#callback#register({
      \           body -> vsnip#anonymous(body)
      \     }),
      \     enableResolveItem: v:true,
      \     enableAdditionalTextEdit: v:true,
      \   }
      \ })

" ------------------------------------------------------------------------------
" 自動補完イベント設定
" ------------------------------------------------------------------------------
" 補完をトリガーするイベント
" - InsertEnter: インサートモード開始時
" - TextChangedI: インサートモードでテキスト変更時
" - TextChangedP: 補完メニュー表示中のテキスト変更時
" - CmdlineChanged: コマンドライン変更時
call ddc#custom#patch_global('autoCompleteEvents', [
	\ 'InsertEnter', 'TextChangedI', 'TextChangedP', 'CmdlineChanged'])

" ------------------------------------------------------------------------------
" コマンドライン補完設定
" ------------------------------------------------------------------------------
" ':'を押した時にコマンドライン補完を有効化
nnoremap :       <Cmd>call CommandlinePre()<CR>:

" コマンドライン補完開始時の処理
function! CommandlinePre() abort
  " コマンドラインモード用のキーマッピング設定
  " Tab/S-Tab: 補完候補を選択
  cnoremap <Tab>   <Cmd>call pum#map#insert_relative(+1)<CR>
  cnoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
  " Ctrl-n/p: 補完候補を選択（Vim標準のキーバインド）
  cnoremap <C-n>   <Cmd>call pum#map#insert_relative(+1)<CR>
  cnoremap <C-p>   <Cmd>call pum#map#insert_relative(-1)<CR>
  " Ctrl-y: 補完を確定
  cnoremap <C-y>   <Cmd>call pum#map#confirm()<CR>
  " Ctrl-e: 補完をキャンセル
  cnoremap <C-e>   <Cmd>call pum#map#cancel()<CR>

  " コマンドライン用のソースに切り替え
  " 元の設定を保存しておき、後で復元する
  if !exists('b:prev_buffer_config')
    let b:prev_buffer_config = ddc#custom#get_buffer()
  endif
  " Vimスクリプト補完(necovim)と周辺単語補完(around)を使用
  call ddc#custom#patch_buffer('cmdlineSources',
  \ ['necovim', 'around'])

  " コマンドライン終了時に設定を復元
  autocmd User DDCCmdlineLeave ++once call CommandlinePost()
  autocmd InsertEnter <buffer> ++once call CommandlinePost()

  " コマンドライン補完を有効化
  call ddc#enable_cmdline_completion()
endfunction

" コマンドライン補完終了時の処理
function! CommandlinePost() abort
  " コマンドラインモード用のキーマッピングを解除
  silent! cunmap <Tab>
  silent! cunmap <S-Tab>
  silent! cunmap <C-n>
  silent! cunmap <C-p>
  silent! cunmap <C-y>
  silent! cunmap <C-e>

  " 元のソース設定を復元
  if exists('b:prev_buffer_config')
    call ddc#custom#set_buffer(b:prev_buffer_config)
    unlet b:prev_buffer_config
  else
    call ddc#custom#set_buffer({})
  endif
endfunction

" ------------------------------------------------------------------------------
" インサートモード用キーマッピング
" ------------------------------------------------------------------------------
" TAB: 補完メニュー表示中は次の候補、それ以外は条件に応じて動作
" - 行頭または空白の後: 通常のTAB入力
" - それ以外: 手動補完をトリガー
inoremap <silent><expr> <TAB>
      \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
      \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
      \ '<TAB>' : ddc#map#manual_complete()
inoremap <S-Tab>  <Cmd>call pum#map#insert_relative(-1)<CR>

" 上下キー: 補完メニュー表示中は候補選択
imap <silent><expr> <Down>
      \ pum#visible() ? '<Cmd>call pum#map#select_relative(+1)<CR>' :
      \ '<Down>'
imap <silent><expr><Up>
      \ pum#visible() ? '<Cmd>call pum#map#select_relative(-1)<CR>' :
      \ '<Up>'

" Enter: 補完メニュー表示中は確定、それ以外は通常の改行
imap <silent><expr> <CR>
      \ pum#visible() ? '<Cmd>call pum#map#confirm()<CR>' :
      \ '<CR>'

" 補完候補ナビゲーション用のキーマッピング
inoremap <Tab> <Cmd>call pum#map#insert_relative(+1)<CR>
inoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-n>   <Cmd>call pum#map#insert_relative(+1)<CR>
inoremap <C-p>   <Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-y>   <Cmd>call pum#map#confirm()<CR>
inoremap <C-e>   <Cmd>call pum#map#cancel()<CR>
" PageDown/PageUp: ページ単位で候補を移動
inoremap <PageDown> <Cmd>call pum#map#insert_relative_page(+1)<CR>
inoremap <PageUp>   <Cmd>call pum#map#insert_relative_page(-1)<CR>

" ddc.vimを有効化
call ddc#enable()
