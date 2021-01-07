# poetry補完機能追加用PATH
fpath+=~/.zfunc

# zsh-completions(補完機能)の設定
if [ -e /usr/local/share/zsh-completions ]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

autoload -U compinit
compinit -u

autoload -U bashcompinit
bashcompinit

# カラーを追加
autoload -Uz colors
colors

# プロンプト設定
PROMPT='%F{2}%~%f %F{6}$%f '

# ビープ音を消す
setopt nolistbeep

# pyenv環境変数設定
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# poetry環境変数設定
export PATH=$PATH:$HOME/.poetry/bin

# Created by `userpath` on 2020-04-01 08:17:31
export PATH="$PATH:/Users/ryosuke/.local/bin"

# homebrewのwarining解決
alias brew="env PATH=${PATH/\/Users\/ryosuke\/\.pyenv\/shims:/} brew"

# pipxの補完機能を追加
eval "$(register-python-argcomplete pipx)"export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# homebrewへPATHを通す
export PATH="/usr/local/sbin:$PATH"

# rbenvのPATH
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# ポスグレ用
export PATH=$PATH:/Library/PostgreSQL/11/bin

# nodebrew環境PATH
export PATH=$HOME/.nodebrew/current/bin:$PATH

# Rust
export PATH="$HOME/.cargo/bin:$PATH"alias ls='exa --time-style=long-iso -g'

export XDG_BASE_HOME='~/.config'
export TERM=xterm-256color

# neovim
alias vim='nvim'
alias vi='nvim'

# general use
alias ls='exa'                                                          # ls
alias l='exa -lbF --git'                                                # list, size, type, git
alias ll='exa -lbGF --git'                                             # long list
alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

# specialty views
alias lS='exa -1'                                                              # one column, just names
alias lt='exa --tree --level=2'                                         # tree

# pip-upgrade-allで更新可能なパッケージを一括アップデート
alias pip-upgrade-all="pip list -o | tail -n +3 | awk '{ print \$1 }' | xargs pip install -U"

fpath+=${ZDOTDIR:-~}/.zsh_functions
