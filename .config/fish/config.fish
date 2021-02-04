starship init fish | source

set -U FZF_LEGACY_KEYBINDINGS 0

pyenv init - | source

set -x PATH $HOME/.nodebrew/current/bin $PATH

# general use
alias ls='exa'                                                          # ls
alias lla='exa -la'
alias l='exa -lbF --git'                                                # list, size, type, git
alias ll='exa -lbGF --git'                                             # long list
alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

# specialty views
alias lS='exa -1'                                                              # one column, just names
alias lt='exa --tree --level=2'                                         # tree

# neovim
abbr vim 'nvim'
abbr vi 'nvim'

# pip-upgrade-allで更新可能なパッケージを一括アップデート
alias pip-upgrade-all="pip list -o | tail -n +3 | awk '{ print \$1 }' | xargs pip install -U"

# 端末起動時にtmuセッション起動
function attach_tmux_session_if_needed
    set ID (tmux list-sessions)
    if test -z "$ID"
        tmux new-session
        return
    end

    set new_session "Create New Session" 
    set ID (echo $ID\n$new_session | peco --on-cancel=error | cut -d: -f1)
    if test "$ID" = "$new_session"
        tmux new-session
    else if test -n "$ID"
        tmux attach-session -t "$ID"
    end
end

if test -z $TMUX && status --is-login
    attach_tmux_session_if_needed
end

set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin
set -g fish_user_paths "/usr/local/opt/curl/bin" $fish_user_paths
