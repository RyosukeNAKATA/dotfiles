# bash-complition
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

set completion-ignore-case on

# カラーを追加
set colored-stats on
set colored-completion-prefix on
set visible-stats on

# Created by `userpath` on 2020-04-01 08:17:31
export PATH="$PATH:/Users/ryosuke/.local/bin"
# homebrew
export PATH="$PATH:/opt/homebrew/bin/"
# Rust
export PATH="$HOME/.cargo/bin:$PATH"
# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# poetry
$HOME/.poetry/bin:$PATH
export PATH=$PATH:$HOME/.poetry/bin
# postgresql
export PATH=$PATH:/Library/PostgreSQL/11/bin
# starship
eval "$(starship init bash)"

export XDG_BASE_HOME='~/.config'
export TERM=xterm-256color

# neovim
alias vim='nvim'
alias vi='nvim'

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
# git
alias ga='git add'
alias gc="git commit -m ''"
alias gp='git push'
alias grm='git rm -r --cached .'