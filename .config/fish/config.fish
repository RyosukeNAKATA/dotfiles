# PATH
# starship
starship init fish | source
# pyenv
status is-login; and pyenv init --path | source
pyenv init - | source
set -x PATH $HOME/.pyenv/bin $PATH
# poetry
# set PATH=$PATH:$HOME/.poetry/bin
# postgresql
set -x PGDATA /usr/local/var/postgres/
# userpath
set PATH $PATH /Users/ryosuke/.local/bin
# Rust
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin
# zoxide
zoxide init fish | source
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
abbr lS 'exa -1 --icons'                                                              # one column, just names
abbr lt 'exa --tree --level=2 --icons'                                         # tree
abbr tree 'exa -T --icons'
# cat
abbr cat 'bat'
abbr catall 'bat -A'
# find
abbr = find 'fd'
abbr = finde 'fd -e'
abbr = findh 'fd -H'
abbr = findi 'fd -I'
# copy
abbr cp 'xcp'
# ps
abbr ps 'procs'
# z
abbr z 'zoxide'
# git
abbr ga 'git add -A'
abbr gc "git commit -m ''"
abbr gps 'git push'
abbr gpl 'git pull'
abbr grm 'git rm -r --cached .'
# neovim
abbr vim 'nvim'
abbr vi 'nvim'
# jupyter lab
abbr jl 'jupyter-lab'

abbr memo 'nvim memo.md'

set -g take 'https://neuro.dob.jp/~takefuji'fish_add_path /usr/local/opt/curl/bin
