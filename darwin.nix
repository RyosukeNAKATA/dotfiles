{ pkgs, user, hostname, ... }:

{
  # プライマリユーザー設定 (nix-darwin)
  system.primaryUser = user;

  # Nix ビルドユーザーの GID 修正 (Determinate/Nix インストーラーと同期)
  ids.gids.nixbld = 350;

  # Unfree パッケージ (zsh-abbr 等) の許可
  nixpkgs.config.allowUnfree = true;

  # Nix の設定
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # システムレベルでシンリンクを作成するパス
  environment.pathsToLink = [ "/share/tmux-plugins" ];

  # システム状態のバージョン
  system.stateVersion = 4;

  # macOS のキーボード・Finder・Dock のデフォルト設定
  system.defaults = {
    dock = {
      autohide = false;
      show-recents = false;
    };
    finder = {
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      "com.apple.swipescrolldirection" = true; # ナチュラルスクロール
    };
  };

  # ユーザー設定
  users.users."${user}" = {
    name = user;
    home = "/Users/${user}";
  };

  # Homebrew 宣言的一括管理
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none"; # 既存手動インストールと共存しやすいよう safe に設定
    };

    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "olets/tap"
      "wez/wezterm"
    ];

    brews = [
      "alp"
      "awscli"
      "bat"
      "cmake"
      "desktop-file-utils"
      "eza"
      "fd"
      "fzf"
      "gcc"
      "gh"
      "gitui"
      "glow"
      "imagemagick"
      "jq"
      "jql"
      "libyaml"
      "mise"
      "neofetch"
      "neovim"
      "ripgrep"
      "starship"
      "tmux"
      "tree-sitter"
      "wget"
      "yazi"
      "zoxide"
    ];

    casks = [
      "alacritty"
      "appcleaner"
      "font-fira-code"
      "font-hackgen-nerd"
      "obsidian"
      "raycast"
      "wezterm"
    ];
  };
}
