starship init fish | source
# Rust
export PATH="$HOME/.cargo/bin:$PATH"alias ls='exa --time-style=long-iso -g'
export XDG_BASE_HOME='~/.config'
export TERM=xterm-256color
# pyenv
status is-login; and pyenv init --path | source
pyenv init - | source
set -x PATH $HOME/.pyenv/bin $PATH
# volta
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
# for fish
set -U fish_user_paths (echo $fish_user_paths | tr ' ' '\n' | sort -u)

# general use for rewrite in rust
abbr ls 'exa -F --icons' 
abbr lls 'exa -lF --icons'
abbr lla 'exa -laF --icons'
abbr l 'exa -lbF --git --icons'
abbr ll 'exa -lbGF --git --icons'
abbr llm 'exa -lbGd --git --sort=modified --icons'
abbr la 'exa -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons'
abbr lx 'exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --icons'
# specialty views
abbr lS 'exa -1 --icons'
abbr tree 'exa -T --icons'
# cat
abbr cat 'bat'
abbr catall 'bat -A'
# find
abbr find 'fd'
abbr finde 'fd -e'
abbr findh 'fd -H'
abbr findi 'fd -I'
# copy
abbr cp 'xcp'
# z
abbr z 'zoxide'
# git
abbr ga 'git add -A'
abbr gc "git commit -m ''"
abbr gps 'git push origin '
abbr gpl 'git pull origin '
# neovim
abbr vim 'nvim'
abbr vi 'nvim'
abbr emacs 'nvim'

abbr grm 'git rm -r --cached .'
