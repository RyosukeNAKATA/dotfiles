#
# ~/.bashrc
#
eval "$(starship init bash)"
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"

# neovim
alias vim='nvim'
alias vi='nvim'

# general use
alias ls='exa -F'
alias lls='exa -Fl'                                                          # ls
alias l='exa -lbF --git'                                                # list, size, type, git
alias ll='exa -lbGF --git'                                             # long list
alias lla='exa -Fla'   
alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

# specialty views
alias lS='exa -1'                                                              # one column, just names
alias lt='exa --tree --level=2'                                         # tree

alias cat='bat'
alias cat='bat'
alias catall='bat -A'

. "$HOME/.cargo/env"