# Nushell 環境設定ファイル
# chezmoi によって管理されています

$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"

# PATH 設定
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend '/run/current-system/sw/bin'
    | prepend '/nix/var/nix/profiles/default/bin'
    | prepend '/opt/homebrew/bin'
    | prepend $'($env.HOME)/.cargo/bin'
    | prepend $'($env.HOME)/.local/bin'
    | prepend $'($env.HOME)/.lmstudio/bin'
    | uniq
)

# FZF 設定
$env.FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git"'
$env.FZF_DEFAULT_OPTS = '--height 70% --reverse --border'

# Pure Prompt スタイルのプロンプト (Iceberg Dark カラーテーマ)
# Iceberg の配色:
# - 青 (#84a0c6): カレントディレクトリ
# - 緑 (#b4be82): Git ブランチ
# - マゼンタ (#a093c7): デフォルトのプロンプトインジケータ
# - 赤 (#e27878): エラー時のプロンプトインジケータ
# - グレー (#6b7089): 詳細・複数行インジケータ

def create_left_prompt [] {
    let home = ($env.HOME | path expand)
    let pwd_path = (pwd | path expand)
    let dir = (
        if ($pwd_path == $home) {
            "~"
        } else if ($pwd_path | str starts-with $"($home)/") {
            $"~($pwd_path | str substring ($home | str length)..)"
        } else {
            $pwd_path
        }
    )
    let dir_styled = $"(ansi { fg: "#84a0c6" })($dir)(ansi reset)"
    
    let git_info = (
        if (which git | is-not-empty) {
            let is_git = (do { git rev-parse --is-inside-work-tree } | complete)
            if $is_git.exit_code == 0 and ($is_git.stdout | str trim) == "true" {
                let branch_res = (do { git branch --show-current } | complete)
                let branch = if $branch_res.exit_code == 0 { $branch_res.stdout | str trim } else { "" }
                let branch_name = if ($branch | is-empty) {
                    let head_res = (do { git rev-parse --short HEAD } | complete)
                    if $head_res.exit_code == 0 { $head_res.stdout | str trim } else { "" }
                } else {
                    $branch
                }

                let status_res = (do { git status --porcelain } | complete)
                let status_lines = if $status_res.exit_code == 0 { $status_res.stdout | lines } else { [] }
                let has_staged = ($status_lines | any {|line| let c = ($line | str substring 0..1); $c != " " and $c != "?" })
                let has_unstaged = ($status_lines | any {|line| let c = ($line | str substring 1..2); $c != " " and $c != "?" })
                let has_untracked = ($status_lines | any {|line| $line | str starts-with "??" })

                let staged_sym = if $has_staged { $"(ansi { fg: "#b4be82" })+(ansi reset)" } else { "" }
                let unstaged_sym = if $has_unstaged { $"(ansi { fg: "#e2a478" })*(ansi reset)" } else { "" }
                let untracked_sym = if $has_untracked { $"(ansi { fg: "#e27878" })?(ansi reset)" } else { "" }

                let ahead_res = (do { git rev-list --count @{u}..HEAD } | complete)
                let ahead = if $ahead_res.exit_code == 0 { $ahead_res.stdout | str trim } else { "0" }

                let behind_res = (do { git rev-list --count HEAD..@{u} } | complete)
                let behind = if $behind_res.exit_code == 0 { $behind_res.stdout | str trim } else { "0" }
                
                let ahead_sym = if ($ahead != "0" and $ahead != "") { $"(ansi { fg: "#a093c7" })↑($ahead)(ansi reset)" } else { "" }
                let behind_sym = if ($behind != "0" and $behind != "") { $"(ansi { fg: "#89b8c2" })↓($behind)(ansi reset)" } else { "" }

                let branch_styled = $"(ansi { fg: "#b4be82" })($branch_name)(ansi reset)"
                $" ($branch_styled)($staged_sym)($unstaged_sym)($untracked_sym)($ahead_sym)($behind_sym)"
            } else {
                ""
            }
        } else {
            ""
        }
    )
    
    $"($dir_styled)($git_info)\n"
}

$env.PROMPT_COMMAND = { create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { "" }

$env.PROMPT_INDICATOR = {
    let last_exit_code = $env.LAST_EXIT_CODE? | default 0
    let indicator_color = if $last_exit_code == 0 { "#a093c7" } else { "#e27878" }
    $"(ansi { fg: $indicator_color })❯ (ansi reset)"
}

$env.PROMPT_INDICATOR_VI_INSERT = { $"(ansi { fg: "#a093c7" })❯ (ansi reset)" }
$env.PROMPT_INDICATOR_VI_NORMAL = { $"(ansi { fg: "#89b8c2" })❮ (ansi reset)" }
$env.PROMPT_MULTILINE_INDICATOR = { $"(ansi { fg: "#6b7089" })::: (ansi reset)" }

# 静的解析用に zoxide ファイルが存在することを確認
let zoxide_file = $'($env.HOME)/.zoxide.nu'
if not ($zoxide_file | path exists) {
    "" | save -f $zoxide_file
}
if (which zoxide | is-not-empty) {
    zoxide init nushell | save -f $zoxide_file
}

# 静的解析用に carapace ファイルが存在することを確認
let carapace_cache = $'($env.HOME)/.cache/carapace'
let carapace_file = $'($carapace_cache)/init.nu'
if not ($carapace_cache | path exists) {
    mkdir $carapace_cache
}
if not ($carapace_file | path exists) {
    "" | save -f $carapace_file
}
if (which carapace | is-not-empty) {
    carapace _carapace nushell | save -f $carapace_file
}

# mise の初期化
if (which mise | is-not-empty) {
    $env.MISE_SHELL = "nu"
}
