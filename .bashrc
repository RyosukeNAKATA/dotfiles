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

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

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
alias tree='exa -T'
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