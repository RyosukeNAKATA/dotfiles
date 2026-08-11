# ==============================================================================
# エイリアス定義
# ==============================================================================
# Nushell ls によるファイル・ディレクトリ一覧定義
alias l = ls
alias la = ls -a
alias ll = ls -l
alias lls = ls -l
alias lla = ls -la
alias lx = ls -la

# eza によるツリー表示 (深さ2)
alias lt = eza --tree --level=2 --icons

# eza によるツリー表示
alias tree = eza -T --icons

# bat
alias catall = bat -A

# fd
alias finde = fd -e
alias findh = fd -H
alias findi = fd -I

# git
alias ga = git add -A
alias gc = git checkout
alias gcm = git commit -m
alias gps = git push
alias gpl = git pull
alias grm = git rm -r --cached .

# gitui
alias gu = gitui

# neovim
alias nv = nvim

# cargo-compete
alias compete = cargo compete

# グローバルIP表示
alias gip = curl inet-ip.info

# ripgrep
alias rp = rg "" --sort path -n --color always

# GitHub Copilot
alias cli = copilot --banner

# opencode
alias oc = opencode

# claude
alias cl = claude

# docker
alias dr = docker compose run --rm rails bundle exec
