# ==============================================================================
# zsh General Settings
# ==============================================================================
setopt no_beep
export HISTSIZE=10001
export SAVEHIST=100001
export XDG_CONFIG_HOME="$HOME/.config"
setopt hist_ignore_dups

# Nix / Homebrew PATH
[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# ==============================================================================
# fzf Configurations & Widgets
# ==============================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 70% --reverse --border'

function fzf-history-widget() {
    local tac=${commands[tac]:-"tail -r"}
    BUFFER=$( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed 's/ *[0-9]* *//' | eval $tac | awk '!a[$0]++' | fzf +s)
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

fzf-file-widget() {
  local selected_file=$(fd -t file | fzf --preview "bat --style=numbers --color=always {}")
  BUFFER="${BUFFER:0:$CURSOR}$selected_file${BUFFER:$CURSOR}"
  CURSOR=$((CURSOR + ${#selected_file}))
  zle redisplay
}
zle -N fzf-file-widget
bindkey '^T' fzf-file-widget

fzf-rg-widget() {
  BUFFER="rg \"\" --sort path -n --color always --no-heading"
  CURSOR=4
  zle redisplay
}
zle -N fzf-rg-widget
bindkey '^P' fzf-rg-widget

# ==============================================================================
# Shell Integrations & Environment Hooks
# ==============================================================================
type zoxide &>/dev/null && eval "$(zoxide init zsh)"
type mise &>/dev/null && eval "$(mise activate zsh)"

# PATH
export PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$HOME/.local/bin:$HOME/.lmstudio/bin:$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# ==============================================================================
# Aliases
# ==============================================================================
alias lls='eza -lF --icons'
alias la='eza -laF --icons'
alias l='eza -lbF --git --icons'
alias ll='eza -lbGF --git --icons'
alias llm='eza -lbGd --git --sort=modified --icons'
alias lla='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --icons'
alias lt='eza --tree --level=2 --icons'
alias tree='eza -T --icons'
alias catall='bat -A'
alias finde='fd -e'
alias findh='fd -H'
alias findi='fd -I'
alias ga='git add -A'
alias gc='git checkout'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias grm='git rm -r --cached .'
alias gu='gitui'
alias nv='nvim'
alias compete='cargo compete'
alias gip='curl inet-ip.info'
alias rp='rg "" --sort path -n --color always'
alias cli='copilot --banner'
alias oc='opencode'
alias cl='claude'
alias dr='docker compose run --rm rails bundle exec'
