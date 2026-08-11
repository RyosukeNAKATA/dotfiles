# ==============================================================================
# bash General Settings
# ==============================================================================
[ -z "$PS1" ] && return

HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Nix / Homebrew PATH
[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Shell Integrations
type starship &>/dev/null && eval "$(starship init bash)"
type zoxide &>/dev/null && eval "$(zoxide init bash)"

# PATH
export PATH="$HOME/.local/bin:$HOME/.lmstudio/bin:$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Aliases
alias lls='eza -lF --icons'
alias la='eza -laF --icons'
alias ll='eza -lbGF --git --icons'
alias catall='bat -A'
alias nv='nvim'
alias gu='gitui'
alias cl='claude'
