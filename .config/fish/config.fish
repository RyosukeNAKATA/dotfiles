# general use for rewrite in rust
alias ls='exa -F'   
alias lls='exa -lF'                                                       # ls
alias lla='exa -laF'
alias l='exa -lbF --git'                                                # list, size, type, git
alias ll='exa -lbGF --git'                                             # long list
alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
# specialty views
alias lS='exa -1'                                                              # one column, just names
alias lt='exa --tree --level=2'                                         # tree
abbr tree 'exa -T'

alias cat='bat'
alias catall='bat -A'

alias find='fd'
alias finde='fd -e'
alias findh='fd -H'
alias findi='fd -I'

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

# PATH
starship init fish | source

status is-login; and pyenv init --path | source
pyenv init - | source
set -x PATH $HOME/.pyenv/bin $PATH
eval (nodenv init - | source)
set -x PGDATA /usr/local/var/postgres/
set PATH $PATH /Users/ryosuke/.local/bin
zoxide init fish | source
set -U fish_user_paths (echo $fish_user_paths | tr ' ' '\n' | sort -u)

set -g take 'https://neuro.dob.jp/~takefuji'