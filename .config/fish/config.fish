starship init fish | source

set -U FZF_LEGACY_KEYBINDINGS 0

set -x PATH $HOME/.pyenv/bin $PATH
. (pyenv init - | psub)
eval (nodenv init - | source)
set -x PGDATA /usr/local/var/postgres/

# general use
alias ls='exa'                                                          # ls
alias lla='exa -la'
alias l='exa -lbF --git'                                                # list, size, type, git
alias ll='exa -lbGF --git'                                             # long list
alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
# specialty views
alias lS='exa -1'                                                              # one column, just names
alias lt='exa --tree --level=2'                                         # tree

alias cat='bat'
alias cat='bat'
alias catall='bat -A'

alias find='fd'
alias finde='fd -e'
alias findh='fd -H'
alias findi='fd -I'

# git
abbr ga 'git add'
abbr gc "git commit -m ''"
abbr gp 'git push'

# neovim
abbr vim 'nvim'
abbr vi 'nvim'
# jupyter lab
abbr jl 'jupyter-lab'
# pipx-upgrade-all
alias pip-upgrade-all="pip list -o | tail -n +3 | awk '{ print \$1 }' | xargs pip install -U"

# Created by `userpath` on 2021-02-15 13:14:49
set PATH $PATH /Users/ryosuke/.local/bin

set -U fish_user_paths (echo $fish_user_paths | tr ' ' '\n' | sort -u)

