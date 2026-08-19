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
# Prompt (Iceberg Dark: config/nushell/env.nu の配色・構成に合わせたカスタムプロンプト)
# ==============================================================================
setopt prompt_subst
autoload -Uz vcs_info add-zsh-hook

zstyle ':vcs_info:git:*' formats ' %F{#b4be82}%b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{#b4be82}%b%f %F{#b4be82}+%a%f'

# git status 等の取得はリポジトリが大きいと重くなるため、プロンプト自体は
# 即座に描画し、git 情報だけバックグラウンドジョブで非同期取得して
# 完了後にシグナル経由で再描画する (pure-prompt 方式)。
typeset -g PROMPT_GIT_INFO=""
typeset -g PROMPT_GIT_LAST_PWD=""
typeset -g PROMPT_GIT_JOB_PID=0
typeset -g PROMPT_GIT_TMPFILE="${TMPDIR:-/tmp}/zsh-prompt-git-$$"

function _prompt_git_info_done() {
    [[ -f $PROMPT_GIT_TMPFILE ]] || return
    PROMPT_GIT_INFO="$(<$PROMPT_GIT_TMPFILE)"
    command rm -f "$PROMPT_GIT_TMPFILE"
    PROMPT_GIT_JOB_PID=0
    zle 2>/dev/null && zle reset-prompt
}
trap '_prompt_git_info_done' USR1

function prompt_git_precmd() {
    # precmd 内で git コマンドを実行すると $? が上書きされるため、
    # 直前コマンドの終了ステータスを最初に退避しておく。
    if (( $? == 0 )); then
        prompt_arrow_color="#a093c7"
    else
        prompt_arrow_color="#e27878"
    fi

    # ディレクトリを移動した場合は古い(別リポジトリの)git情報を表示し続けない
    if [[ $PWD != $PROMPT_GIT_LAST_PWD ]]; then
        PROMPT_GIT_INFO=""
    fi
    PROMPT_GIT_LAST_PWD=$PWD

    # 前回のジョブがまだ走っていれば止めてから起動し直す
    # (zsh 組み込み kill はジョブ管理の通知を漏らすことがあるため command kill を使う)
    if (( PROMPT_GIT_JOB_PID )); then
        command kill "$PROMPT_GIT_JOB_PID" 2>/dev/null
    fi

    (
        vcs_info
        if [[ -n $vcs_info_msg_0_ ]]; then
            local line staged_sym unstaged_sym untracked_sym ahead behind ahead_sym behind_sym
            local -a status_lines
            status_lines=("${(@f)$(git status --porcelain 2>/dev/null)}")

            local has_staged=0 has_unstaged=0 has_untracked=0
            for line in $status_lines; do
                [[ -z $line ]] && continue
                if [[ $line == \?\?* ]]; then
                    has_untracked=1
                    continue
                fi
                [[ ${line[1]} != " " ]] && has_staged=1
                [[ ${line[2]} != " " ]] && has_unstaged=1
            done

            (( has_staged )) && staged_sym="%F{#b4be82}+%f"
            (( has_unstaged )) && unstaged_sym="%F{#e2a478}*%f"
            (( has_untracked )) && untracked_sym="%F{#e27878}?%f"

            if git rev-parse --abbrev-ref '@{u}' &>/dev/null; then
                ahead=$(git rev-list --count '@{u}..HEAD' 2>/dev/null)
                behind=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null)
                [[ -n $ahead && $ahead != 0 ]] && ahead_sym="%F{#a093c7}↑${ahead}%f"
                [[ -n $behind && $behind != 0 ]] && behind_sym="%F{#89b8c2}↓${behind}%f"
            fi

            print -r -- "${vcs_info_msg_0_}${staged_sym}${unstaged_sym}${untracked_sym}${ahead_sym}${behind_sym}" > "$PROMPT_GIT_TMPFILE"
        else
            : > "$PROMPT_GIT_TMPFILE"
        fi
        command kill -s USR1 $$
    ) &!
    PROMPT_GIT_JOB_PID=$!
}
add-zsh-hook precmd prompt_git_precmd

PROMPT='%F{#84a0c6}%~%f${PROMPT_GIT_INFO}
%F{${prompt_arrow_color}}❯%f '
PROMPT2='%F{#6b7089}:::%f '

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
