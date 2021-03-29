if g:dein#_cache_version !=# 150 || g:dein#_init_runtimepath !=# '/Users/ryosuke/.config/nvim,/etc/xdg/nvim,/Users/ryosuke/.local/share/nvim/site,/usr/local/share/nvim/site,/usr/share/nvim/site,/usr/local/Cellar/neovim/0.4.4_2/share/nvim/runtime,/usr/share/nvim/site/after,/usr/local/share/nvim/site/after,/Users/ryosuke/.local/share/nvim/site/after,/etc/xdg/nvim/after,/Users/ryosuke/.config/nvim/after,/Users/ryosuke/dotfiles/.cache/dein/repos/github.com/Shougo/dein.vim' | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['/Users/ryosuke/dotfiles/.config/nvim/init.vim', '/Users/ryosuke/dotfiles/.config/nvim/dein.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/Users/ryosuke/dotfiles/.cache/dein'
let g:dein#_runtime_path = '/Users/ryosuke/dotfiles/.cache/dein/.cache/init.vim/.dein'
let g:dein#_cache_path = '/Users/ryosuke/dotfiles/.cache/dein/.cache/init.vim'
let &runtimepath = '/Users/ryosuke/.config/nvim,/etc/xdg/nvim,/Users/ryosuke/.local/share/nvim/site,/usr/local/share/nvim/site,/usr/share/nvim/site,/Users/ryosuke/dotfiles/.cache/dein/repos/github.com/neoclide/coc.nvim_release,/Users/ryosuke/dotfiles/.cache/dein/repos/github.com/Shougo/dein.vim,/Users/ryosuke/dotfiles/.cache/dein/.cache/init.vim/.dein,/usr/local/Cellar/neovim/0.4.4_2/share/nvim/runtime,/Users/ryosuke/dotfiles/.cache/dein/.cache/init.vim/.dein/after,/usr/share/nvim/site/after,/usr/local/share/nvim/site/after,/Users/ryosuke/.local/share/nvim/site/after,/etc/xdg/nvim/after,/Users/ryosuke/.config/nvim/after'
filetype off
source ~/dotfiles/.config/nvim/plugins/pep8.vim
source ~/dotfiles/.config/nvim/plugins/rust.vim
source ~/dotfiles/.config/nvim/plugins/vim-quickrun.vim
source ~/dotfiles/.config/nvim/plugins/cocnvim.vim
