# poetry補完機能追加用PATH
fpath+=~/.zfunc
# zsh-completions(補完機能)の設定
if [ -e /usr/local/share/zsh-completions ]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi
autoload -U compinit
compinit -u
# カラーを追加
autoload -Uz colors
colors
# プロンプト設定
PROMPT='%F{2}%~%f %F{6}$%f '
# ビープ音を消す
setopt nolistbeep

# Created by `userpath` on 2020-04-01 08:17:31
export PATH="$PATH:/Users/ryosuke/.local/bin"
# homebrew
alias brew="env PATH=${PATH/\/Users\/ryosuke\/\.pyenv\/shims:/} brew"
export PATH="/usr/local/sbin:$PATH"
# Rust
export PATH="$HOME/.cargo/bin:$PATH"
# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# poetry
export PATH=$PATH:$HOME/.poetry/bin
# postgresql
export PATH=$PATH:/Library/PostgreSQL/11/bin
# starship
eval "$(starship init zsh)"

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