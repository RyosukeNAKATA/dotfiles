# Nushell 設定ファイル
# chezmoi によって管理されています

# conf.d 内の設定（theme, alias, functions など）を一括読み込み
source conf.d/index.nu

# Nushell メイン設定
$env.config = {
    show_banner: false
    color_config: $iceberg_theme
    
    history: {
        file_format: "plaintext"
        max_size: 100000
        sync_on_enter: true
        isolation: false
    }

    keybindings: [
        {
            name: fzf_file_search
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "commandline edit --insert (fd -t file | fzf --preview 'bat --style=numbers --color=always {}')"
            }
        }
        {
            name: fzf_ripgrep_search
            modifier: control
            keycode: char_p
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "commandline edit --insert 'rg \"\" --sort path -n --color always '"
            }
        }
    ]
}

# ==============================================================================
# 外部ツール連携の読み込み
# ==============================================================================
# zoxide の連携設定
source ~/.zoxide.nu

# carapace 補完の連携設定
source ~/.cache/carapace/init.nu
