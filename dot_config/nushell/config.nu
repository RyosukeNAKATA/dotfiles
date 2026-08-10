# Nushell Config File
# Created for chezmoi dotfiles

# General configuration
$env.config = {
    show_banner: false
}

# Load zoxide integration
if ('~/.zoxide.nu' | path exists) {
    source ~/.zoxide.nu
}

# ==============================================================================
# Aliases
# ==============================================================================
# eza
alias lls = eza -lF --icons
alias la = eza -laF --icons
alias l = eza -lbF --git --icons
alias ll = eza -lbGF --git --icons
alias llm = eza -lbGd --git --sort=modified --icons
alias lla = eza -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons
alias lx = eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --icons
alias lt = eza --tree --level=2 --icons
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

# show global ip
alias gip = curl inet-ip.info

# ripgrep
alias rp = rg "" --sort path -n --color always

# copilot
alias cli = copilot --banner

# opencode
alias oc = opencode

# claude
alias cl = claude

# docker
alias dr = docker compose run --rm rails bundle exec
