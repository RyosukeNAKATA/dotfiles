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
alias ls='exa -F --icons'   
alias lls='exa -lF --icons'                                                       # ls
alias lla='exa -laF --icons'
alias l='exa -lbF --git --icons'                                                # list, size, type, git
alias ll='exa -lbGF --git --icons'                                             # long list
alias llm='exa -lbGd --git --sort=modified --icons'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --icons' # all + extended list
# specialty views
alias lS='exa -1 --icons'                                                              # one column, just names
alias lt='exa --tree --level=2 --icons'                                         # tree
abbr tree 'exa -T --icons'
# cat
alias cat='bat'
alias catall='bat -A'
# find
alias find='fd'
alias finde='fd -e'
alias findh='fd -H'
alias findi='fd -I'
# copy
alias cp='xcp'
# git
abbr ga 'git add'
abbr gc "git commit -m ''"
abbr gp 'git push'

# neovim
abbr vim 'nvim'
abbr vi 'nvim'
# jupyter lab
abbr jl 'jupyter-lab'

set -g take 'https://neuro.dob.jp/~takefuji'