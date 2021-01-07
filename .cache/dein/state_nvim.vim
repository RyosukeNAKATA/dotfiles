if g:dein#_cache_version !=# 150 || g:dein#_init_runtimepath !=# '/Users/ryosuke/.config/nvim,/etc/xdg/nvim,/Users/ryosuke/.local/share/nvim/site,/usr/local/share/nvim/site,/usr/share/nvim/site,/usr/local/Cellar/neovim/0.4.4/share/nvim/runtime,/usr/share/nvim/site/after,/usr/local/share/nvim/site/after,/Users/ryosuke/.local/share/nvim/site/after,/etc/xdg/nvim/after,/Users/ryosuke/.config/nvim/after,/Users/ryosuke/.cache/dein/repos/github.com/Shougo/dein.vim' | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['/Users/ryosuke/dotfiles/.config/nvim/init.vim', '/Users/ryosuke/.config/nvim/dein.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/Users/ryosuke/.cache/dein'
let g:dein#_runtime_path = '/Users/ryosuke/.cache/dein/.cache/init.vim/.dein'
let g:dein#_cache_path = '/Users/ryosuke/.cache/dein/.cache/init.vim'
let &runtimepath = '/Users/ryosuke/.config/nvim,/etc/xdg/nvim,/Users/ryosuke/.local/share/nvim/site,/usr/local/share/nvim/site,/usr/share/nvim/site,/Users/ryosuke/.cache/dein/.cache/init.vim/.dein,/usr/local/Cellar/neovim/0.4.4/share/nvim/runtime,/Users/ryosuke/.cache/dein/.cache/init.vim/.dein/after,/usr/share/nvim/site/after,/usr/local/share/nvim/site/after,/Users/ryosuke/.local/share/nvim/site/after,/etc/xdg/nvim/after,/Users/ryosuke/.config/nvim/after,/Users/ryosuke/.cache/dein/repos/github.com/Shougo/dein.vim'
filetype off
source ~/.vim/plugins/vim-lsp-settings.vim
source ~/.vim/plugins/rust.vim
source ~/.vim/plugins/vim-quickrun.vim
