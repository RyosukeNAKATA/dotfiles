"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/ryosuke/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
call dein#begin('/Users/ryosuke/.cache/dein')

" Let dein manage dein
" Required:
" call dein#add('/Users/ryosuke/.cache/dein/repos/github.com/Shougo/dein.vim')
" call dein#load_toml('/Users/ryosuke/dotfiles/.config/nvim/dein.toml')
let s:toml_dir  = $HOME . '/dotfiles/.config/nvim' 
let s:toml      = s:toml_dir . '/dein.toml'
let s:lazy_toml = s:toml_dir . '/dein_lazy.toml'
call dein#load_toml(s:toml,      {'lazy': 0})
call dein#load_toml(s:lazy_toml, {'lazy': 1})

" Add or remove your plugins here like this:
call dein#add('Shougo/neosnippet.vim')
call dein#add('Shougo/neosnippet-snippets')

" Required:
call dein#end()

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------
" ==============================================================================
" # Editor settings
" ==============================================================================
set showmode
set showmatch
set title
set inccommand=split
set imdisable
set hidden
set nobackup
set nowritebackup
set conceallevel=0
set cursorline
set clipboard=unnamed,unnamedplus
set smartindent
" Completion
" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300
syntax on
set termguicolors
set t_Co=256
set background=dark
colorscheme iceberg
filetype plugin indent on
set autoindent
set timeoutlen=300 " http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set scrolloff=2
set nowrap
set nojoinspaces
let g:sneak#s_next = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_frontmatter = 1
set printfont=:h10
set printencoding=utf-8
let $LANG='en_US.UTF-8'
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac
set printoptions=paper:letter
" Always draw sign column. Prevent buffer moving when adding/deleting sign.
set signcolumn=yes
" Settings needed for .lvimrc
set exrc
set secure
" Sane splits
set splitright
set splitbelow
" Permanent undo
set undodir=~/.vimdid
set undofile
" Decent wildmenu
set wildmenu
set wildmode=list:longest
set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor
" Use wide tabs
set tabstop=4
set noexpandtab
" Wrapping options
set formatoptions=tc " wrap text and comments using textwidth
set formatoptions+=r " continue comments when pressing ENTER in I mode
set formatoptions+=q " enable formatting of comments with gq
set formatoptions+=n " detect lists for formatting
set formatoptions+=b " auto-wrap in insert mode, and do not wrap old long lines

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Very magic by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" fzf setting
set rtp+=/opt/homebrew/opt/fzf
" ==============================================================================
" # GUI settings
" ==============================================================================
set guifont=HackGen35Nerd\ Console:h15
let g:neovide_refresh_rate=60
" set guioptions-=T " Remove toolbar
set vb t_vb= " No more beeps
set backspace=indent,eol,start" Backspace over newlines
set nofoldenable
set ttyfast
" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2
set relativenumber " Relative line numbers
set number " Also show current absolute line
set diffopt+=iwhite " No whitespace in vimdiff
" Make diffing better: https://vimways.org/2018/the-power-of-diff/
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic
" set colorcolumn=80 " and give me a colored column
:set cc=101
:hi ColorColumn gui=reverse cterm=reverse
set showcmd " Show (partial) command in status line.
" Enable mouse usage (all modes) in terminals
if has('mouse')
  set mouse=a
endif
set shortmess+=c " don't give |ins-completion-menu| messages.
" 日本語文字化け対策
set ttimeout
set ttimeoutlen=50
" Show those damn hidden characters
" Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
set listchars=tab:»-,nbsp:¬,extends:»,precedes:«,trail:•,eol:↲
" insert mode to noemal mode on jj
inoremap <silent> jj <ESC>
inoremap <silent> っｊ <ESC>
" cursor line view
if has('vim_starting')
    " 挿入モード時に非点滅の縦棒タイプのカーソル
    let &t_SI .= "\e[6 q"
    " ノーマルモード時に非点滅のブロックタイプのカーソル
    let &t_EI .= "\e[2 q"
    " 置換モード時に非点滅の下線タイプのカーソル
    let &t_SR .= "\e[4 q"
endif
"インサートモードのままカーソル移動
inoremap <C-f> <C-g>U<Right>
inoremap <C-f><C-f> <C-g>U<ESC><S-a>
"Ctrl+h/lで行頭/末に移動
noremap H ^ 
noremap L $
if has("autocmd")
  augroup redhat
    " In text files, always limit the width of text to 78 characters
    autocmd BufRead *.txt set tw=79
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
  augroup END
endif
" ==============================================================================
" # such langeage settings
" ==============================================================================
" For HTML, CSS, SCSS, SASS
runtime plugins/html.vim
autocmd FileType html        setlocal sw=2 sts=2 ts=2 et
autocmd FileType css         setlocal sw=2 sts=2 ts=2 et
autocmd FileType scss        setlocal sw=2 sts=2 ts=2 et
autocmd FileType sass        setlocal sw=2 sts=2 ts=2 et
" htmlのマッチするタグに%でジャンプ
source $VIMRUNTIME/macros/matchit.vim
command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
