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

