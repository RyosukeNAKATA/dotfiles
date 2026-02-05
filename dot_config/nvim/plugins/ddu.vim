" ==============================================================================
" ddu.vim 設定
" Deno製のUIフレームワーク（ファイラー/ファジーファインダー）
" ==============================================================================

" ------------------------------------------------------------------------------
" グローバル設定（ファジーファインダーUI）
" ------------------------------------------------------------------------------
call ddu#custom#patch_global({
\   'ui': 'ff',
\   'sources': [
\     {
\       'name': 'file_rec',
\       'params': {
\         'ignoredDirectories': ['.git', 'node_modules', 'vendor', '.next']
\       }
\     }
\   ],
\   'sourceOptions': {
\     '_': {
\       'matchers': ['matcher_substring'],
\     },
\   },
\   'filterParams': {
\     'matcher_substring': {
\       'highlightMatched': 'Title',
\     },
\   },
\   'kindOptions': {
\     'file': {
\       'defaultAction': 'open',
\     },
\   },
\   'uiParams': {
\     'ff': {
\       'startFilter': v:true,
\       'prompt': '> ',
\       'split': 'floating',
\     }
\   },
\ })

" ------------------------------------------------------------------------------
" ローカル設定（ファイラーUI）
" ------------------------------------------------------------------------------
" ファイラーモード専用の設定
" サイドバー形式でファイルツリーを表示
call ddu#custom#patch_local('filer', {
\   'ui': 'filer',
\   'sources': [
\     {
\       'name': 'file',
\       'params': {},
\     },
\   ],
\   'sourceOptions': {
\     '_': {
\       'columns': ['icon_filename'],
\     },
\   },
\   'kindOptions': {
\     'file': {
\       'defaultAction': 'open',
\     },
\   },
\   'uiParams': {
\     'filer': {
\       'winWidth': 30,
\       'split': 'vertical',
\       'splitDirection': 'topleft',
\       'sort': 'filename',
\       'sortTreesFirst': 'true',
\     }
\   },
\ })

" ------------------------------------------------------------------------------
" ファジーファインダーUI (ddu-ff) のキーマッピング
" ------------------------------------------------------------------------------
autocmd FileType ddu-ff call s:ddu_my_settings()
function! s:ddu_my_settings() abort
  " Enter: 垂直分割で開く
  nnoremap <buffer><silent> <CR>
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'open', 'params': {'command': 'vsplit'}})<CR>

  " Space: 水平分割で開く
  nnoremap <buffer><silent> <Space>
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'open', 'params': {'command': 'split'}})<CR>

  " a: フィルターウィンドウを開く（絞り込み検索）
  nnoremap <buffer><silent> a
    \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>

  " p: プレビュー表示
  nnoremap <buffer><silent> p
    \ <Cmd>call ddu#ui#do_action('preview')<CR>

  " Esc: dduを閉じる
  nnoremap <buffer><silent> <Esc>
    \ <Cmd>call ddu#ui#do_action('quit')<CR>
endfunction

" ------------------------------------------------------------------------------
" フィルターウィンドウのキーマッピング
" ------------------------------------------------------------------------------
autocmd FileType ddu-ff-filter call s:ddu_filter_my_settings()
function! s:ddu_filter_my_settings() abort
  " Enter: フィルターウィンドウを閉じる（インサートモード）
  inoremap <buffer><silent> <CR>
    \ <Esc><Cmd>close<CR>

  " Esc: フィルターウィンドウを閉じる（インサートモード）
  inoremap <buffer><silent> <Esc>
    \ <Esc><Cmd>close<CR>

  " Enter: フィルターウィンドウを閉じる（ノーマルモード）
  nnoremap <buffer><silent> <CR>
    \ <Cmd>close<CR>

  " Esc: フィルターウィンドウを閉じる（ノーマルモード）
  nnoremap <buffer><silent> <Esc>
    \ <Cmd>close<CR>
endfunction

" ------------------------------------------------------------------------------
" ファイラーUI (ddu-filer) のキーマッピング
" ------------------------------------------------------------------------------
function! s:ddu_filer_my_settings() abort
  " Enter: ディレクトリなら展開、ファイルなら開く
  nnoremap <buffer><silent><expr> <CR>
    \ ddu#ui#get_item()->get('isTree', v:false) ?
    \ "<Cmd>call ddu#ui#do_action('itemAction', {'name': 'narrow'})<CR>" :
    \ "<Cmd>call ddu#ui#do_action('itemAction', {'name': 'open', 'params': {'split': 'no'}})<CR>"

  " Space: ディレクトリなら展開、ファイルなら水平分割で開く
  nnoremap <buffer><silent><expr> <Space>
    \ ddu#ui#get_item()->get('isTree', v:false) ?
    \ "<Cmd>call ddu#ui#do_action('itemAction', {'name': 'narrow'})<CR>" :
    \ "<Cmd>call ddu#ui#do_action('itemAction', {'name': 'open', 'params': {'command': 'split'}})<CR>"

  " Esc/q: ファイラーを閉じる
  nnoremap <buffer><silent> <Esc>
    \ <Cmd>call ddu#ui#do_action('quit')<CR>
  nnoremap <buffer><silent> q
    \ <Cmd>call ddu#ui#do_action('quit')<CR>

  " ..: 親ディレクトリに移動
  nnoremap <buffer><silent> ..
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'narrow', 'params': {'path': '..'}})<CR>

  " ファイル操作
  " c: コピー
  nnoremap <buffer><silent> c
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'copy'})<CR>
  " p: 貼り付け
  nnoremap <buffer><silent> p
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'paste'})<CR>
  " d: 削除
  nnoremap <buffer><silent> d
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'delete'})<CR>
  " r: 名前変更
  nnoremap <buffer><silent> r
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'rename'})<CR>
  " mv: 移動
  nnoremap <buffer><silent> mv
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'move'})<CR>
  " t: 新規ファイル作成
  nnoremap <buffer><silent> t
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'newFile'})<CR>
  " mk: 新規ディレクトリ作成
  nnoremap <buffer><silent> mk
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'newDirectory'})<CR>
  " yy: パスをヤンク
  nnoremap <buffer><silent> yy
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'yank'})<CR>

  " 自動リフレッシュ: タブ切り替え、カーソル静止時、フォーカス時
  autocmd TabEnter,CursorHold,FocusGained <buffer>
    \ call ddu#ui#do_action('checkItems')
endfunction

autocmd FileType ddu-filer call s:ddu_filer_my_settings()

" ------------------------------------------------------------------------------
" グローバルキーマッピング
" ------------------------------------------------------------------------------
" ;f: ファジーファインダーを開く（ファイル検索）
nmap <silent> ;f <Cmd>call ddu#start({})<CR>

" Ctrl-f: カーソル下の単語でripgrep検索
nmap <silent> <C-f> <Cmd>call ddu#start({
\   'name': 'grep',
\   'sources':[
\     {'name': 'rg', 'params': {'input': expand('<cword>')}}
\   ],
\ })<CR>

" Ctrl-b: ファイラーを開く（現在のファイルの位置で）
nmap <silent> <C-b> <Cmd>call ddu#start({
\   'name': 'filer',
\   'searchPath': expand('%:p'),
\ })<CR>
