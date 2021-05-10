starship init fish | source

# neovim
abbr vim 'nvim'
abbr vi 'nvim'

# general use
alias ls='exa -F'                                                          # ls
alias lls='exa -Fl'
alias lla='exa -laF'
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

# git
abbr ga 'git add'
abbr gc "git commit -m ''"
abbr gp 'git push'

# Rust
export PATH="$HOME/.cargo/bin:$PATH"alias ls='exa --time-style=long-iso -g'
export XDG_BASE_HOME='~/.config'
export TERM=xterm-256color

# anyenv
set -x PATH $HOME/.anyenv/bin $PATH
eval (anyenv init - | source)