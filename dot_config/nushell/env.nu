# Nushell Environment Config File
# Created for chezmoi dotfiles

# Set PATH
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend '/opt/homebrew/bin'
    | prepend $'($env.HOME)/.cargo/bin'
    | prepend $'($env.HOME)/.local/bin'
    | prepend $'($env.HOME)/.lmstudio/bin'
    | uniq
)

# Initialize zoxide if available
if (which zoxide | is-not-empty) {
    zoxide init nushell | save -f ~/.zoxide.nu
}
