starship init fish | source

set -U FZF_LEGACY_KEYBINDINGS 0

# set PATH="$HOME/.pyenv/bin:$PATH"
set -U fish_user_paths $HOME/.pyenv/bin $fish_user_paths
# set PATH="/usr/local/bin:$PATH"
set -U fish_user_paths /usr/local/bin $fish_user_paths

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

# neovim
abbr vim 'nvim'
abbr vi 'nvim'

# pipx-upgrade-all
alias pipx-upgrade-all="pip list -o | tail -n +3 | awk '{ print \$1 }' | xargs pipx install -U"

# Created by `userpath` on 2021-02-15 13:14:49
set PATH $PATH /Users/ryosuke/.local/bin

set -U fish_user_paths (echo $fish_user_paths | tr ' ' '\n' | sort -u)