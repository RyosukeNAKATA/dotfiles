#
# ~/.bashrc
#
eval "$(starship init bash)"
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
# volta
. "$HOME/.cargo/env"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

PS1='[\u@\h \W]\$ '

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
alias tree='exa -T --icons'
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

# neovim
alias vim='nvim'
alias vi='nvim'