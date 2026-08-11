{ config, pkgs, lib, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.05";

  # パッケージ（Home Manager 経由で管理）
  home.packages = with pkgs; [
    pure-prompt
    zsh-autopair
    zsh-abbr
    zsh-fast-syntax-highlighting
    tmuxPlugins.tmux-thumbs
    tmuxPlugins.resurrect
    tmuxPlugins.continuum
  ];

  # -----------------------------------------------------------------------------
  # zsh 設定 & プラグイン定義 (sheldon 完全代替)
  # -----------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "pure";
        src = "${pkgs.pure-prompt}/share/zsh/site-functions";
      }
      {
        name = "zsh-autopair";
        src = "${pkgs.zsh-autopair}/share/zsh/zsh-autopair";
        file = "zsh-autopair.plugin.zsh";
      }
      {
        name = "zsh-abbr";
        src = "${pkgs.zsh-abbr}/share/zsh-abbr";
        file = "zsh-abbr.plugin.zsh";
      }
    ];

    shellAliases = {
      lls = "eza -lF --icons";
      la = "eza -laF --icons";
      l = "eza -lbF --git --icons";
      ll = "eza -lbGF --git --icons";
      llm = "eza -lbGd --git --sort=modified --icons";
      lla = "eza -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons";
      lx = "eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --icons";
      lt = "eza --tree --level=2 --icons";
      tree = "eza -T --icons";
      catall = "bat -A";
      finde = "fd -e";
      findh = "fd -H";
      findi = "fd -I";
      ga = "git add -A";
      gc = "git checkout";
      gcm = "git commit -m";
      gps = "git push";
      gpl = "git pull";
      grm = "git rm -r --cached .";
      gu = "gitui";
      nv = "nvim";
      compete = "cargo compete";
      gip = "curl inet-ip.info";
      rp = "rg \"\" --sort path -n --color always";
      cli = "copilot --banner";
      oc = "opencode";
      cl = "claude";
      dr = "docker compose run --rm rails bundle exec";
    };

    initContent = ''
      # zsh 基本設定
      setopt no_beep
      export HISTSIZE=10001
      export SAVEHIST=100001
      export XDG_CONFIG_HOME="$HOME/.config"
      setopt hist_ignore_dups

      # fzf キーバインド・補完
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
      export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
      export FZF_DEFAULT_OPTS='--height 70% --reverse --border'

      function fzf-history-widget() {
          local tac=''${commands[tac]:-"tail -r"}
          BUFFER=$( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed 's/ *[0-9]* *//' | eval $tac | awk '!a[$0]++' | fzf +s)
          CURSOR=$#BUFFER
          zle clear-screen
      }
      zle -N fzf-history-widget
      bindkey '^R' fzf-history-widget

      fzf-file-widget() {
        local selected_file=$(fd -t file | fzf --preview "bat --style=numbers --color=always {}")
        BUFFER="''${BUFFER:0:$CURSOR}$selected_file''${BUFFER:$CURSOR}"
        CURSOR=$((CURSOR + ''${#selected_file}))
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

      # pure prompt の初期化
      autoload -U promptinit; promptinit
      zstyle :prompt:pure:git:branch color green
      prompt pure

      # 各種ツールの初期化フック
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"
      eval "$(mise activate zsh)"

      # Nix daemon & Nix / nix-darwin PATH
      [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      export PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$HOME/.local/bin:$HOME/.lmstudio/bin:$HOME/.cargo/bin:$PATH"
      [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    '';
  };

  # -----------------------------------------------------------------------------
  # ドットファイルの Out-of-Store Symlink 配置
  # -----------------------------------------------------------------------------
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nvim";
  xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/tmux";
  xdg.configFile."alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/alacritty";
  xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/wezterm";
  xdg.configFile."git".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/git";
  xdg.configFile."gitui".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/gitui";
  xdg.configFile."yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/yazi";
  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/zed";
  xdg.configFile."gwq".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/gwq";
  xdg.configFile."neofetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/neofetch";
  xdg.configFile."nushell/config.nu".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nushell/config.nu";
  xdg.configFile."nushell/env.nu".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nushell/env.nu";
  xdg.configFile."nushell/conf.d".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nushell/conf.d";
  xdg.configFile."nushell/functions".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nushell/functions";

  home.file.".claude".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/claude";
  home.file.".gemini".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/gemini";
  home.file.".copilot".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/copilot";

  # Shell dotfiles (.zshrc / .bashrc)
  home.file.".zshrc".text = ''
    # Managed by Nix Home Manager
    export ZDOTDIR="$HOME/.config/zsh"
    [ -f "$ZDOTDIR/.zshrc" ] && source "$ZDOTDIR/.zshrc"
  '';
  xdg.configFile."zsh/.zshrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/zsh/.zshrc";

  home.file.".bashrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/bash/.bashrc";
  home.file.".bash_profile".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/bash/.bashrc";

  # -----------------------------------------------------------------------------
  # Neovim (dpp.vim) 必須プラグイン自動クローン
  # -----------------------------------------------------------------------------
  home.activation.setupDpp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DPP_BASE="$HOME/.cache/dpp/repos/github.com/Shougo"
    DENOPS_BASE="$HOME/.cache/dpp/repos/github.com/vim-denops"
    $DRY_RUN_CMD mkdir -p "$DPP_BASE" "$DENOPS_BASE"

    clone_repo() {
      local url="$1"
      local dest="$2"
      if [ ! -d "$dest" ]; then
        echo "==> Cloning $url to $dest..."
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$url" "$dest"
      fi
    }

    clone_repo "https://github.com/Shougo/dpp.vim.git" "$DPP_BASE/dpp.vim"
    clone_repo "https://github.com/Shougo/dpp-ext-installer.git" "$DPP_BASE/dpp-ext-installer"
    clone_repo "https://github.com/Shougo/dpp-protocol-git.git" "$DPP_BASE/dpp-protocol-git"
    clone_repo "https://github.com/Shougo/dpp-ext-lazy.git" "$DPP_BASE/dpp-ext-lazy"
    clone_repo "https://github.com/Shougo/dpp-ext-toml.git" "$DPP_BASE/dpp-ext-toml"
    clone_repo "https://github.com/vim-denops/denops.vim.git" "$DENOPS_BASE/denops.vim"
  '';
}
