# パッケージ・アプリの追加と削除（管理手順書）

Nix + nix-darwin + Home Manager 環境において、CLI パッケージ・GUI アプリ（Cask）・zsh プラグインの**追加（インストール）**および**削除（アンインストール）**を行う手順を解説します。

---

## 💡 基本の流れ

1. リポジトリ内の定義ファイル（`darwin.nix` または `home.nix`）を編集する
2. 変更を Git でトラックする (`git add .`)
3. 構築反映コマンドを実行する (`sudo darwin-rebuild switch ...`)

---

## 1. GUI アプリ（Cask）やフォントの追加・削除

Mac の GUI アプリ（Raycast, Obsidian, WezTerm 等）やフォントは [`darwin.nix`](file:///Users/ryosuke/.local/share/chezmoi/darwin.nix) の `homebrew.casks` で管理します。

### 追加する手順
[`darwin.nix`](file:///Users/ryosuke/.local/share/chezmoi/darwin.nix) の `homebrew.casks` 配下にパッケージ名を追加します：

```nix
  homebrew = {
    casks = [
      "alacritty"
      "appcleaner"
      "font-fira-code"
      "font-hackgen-nerd"
      "obsidian"
      "raycast"
      "wezterm"
      "slack"             # <-- 追加したい GUI アプリ
      "visual-studio-code" # <-- 追加したい GUI アプリ
    ];
  };
```

### 削除（アンインストール）する手順
`homebrew.casks` のリストから該当する行を削除（またはコメントアウト）します。

---

## 2. CLI パッケージの追加・削除

CLI パッケージ（`ripgrep`, `bat`, `eza`, `fzf` 等）は、[`darwin.nix`](file:///Users/ryosuke/.local/share/chezmoi/darwin.nix) の `homebrew.brews` または [`home.nix`](file:///Users/ryosuke/.local/share/chezmoi/home.nix) の `home.packages` で管理します。

### Homebrew 経由の CLI パッケージ追加・削除
[`darwin.nix`](file:///Users/ryosuke/.local/share/chezmoi/darwin.nix) の `homebrew.brews` を編集：

```nix
  homebrew = {
    brews = [
      "bat"
      "eza"
      "fd"
      "htop"  # <-- 追加したい CLI パッケージ
    ];
  };
```

### Nixpkgs (Nix 公式) 経由の CLI パッケージ追加・削除
[`home.nix`](file:///Users/ryosuke/.local/share/chezmoi/home.nix) の `home.packages` を編集：

```nix
  home.packages = with pkgs; [
    pure-prompt
    zsh-autopair
    zsh-abbr
    htop # <-- Nixpkgs から導入したいパッケージを追加
  ];
```

---

## 3. zsh プラグインの追加・削除

zsh プラグインは [`home.nix`](file:///Users/ryosuke/.local/share/chezmoi/home.nix) の `programs.zsh.plugins` で管理します。

### 追加手順

```nix
  programs.zsh = {
    plugins = [
      {
        name = "pure";
        src = "${pkgs.pure-prompt}/share/zsh/site-functions";
      }
      {
        name = "zsh-autosuggestions";
        src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
      }
    ];
  };
```

---

## 🚀 4. 変更の適用（スイッチ）

定義ファイルを編集・保存したら、ターミナルで以下のコマンドを実行してシステムに反映させます。

> Nix Flake は Git でトラックされているファイルのみを評価するため、設定ファイル編集後・追加後は `git add` が必須です。

### 🐚 zsh で実行する場合

```zsh
cd ~/dotfiles
git add .
sudo darwin-rebuild switch --flake ~/dotfiles#RyosukenoMacBook-Pro
```

### 🐢 Nushell で実行する場合

```nu
cd ~/dotfiles
git add .
sudo darwin-rebuild switch --flake ~/dotfiles#RyosukenoMacBook-Pro
```

---

## 🔄 5. パッケージの更新 (Update)

Flake のロックファイル (`flake.lock`) を更新し、Nix / Homebrew パッケージ全体を最新化するコマンドです。

### 🐚 zsh の場合

```zsh
cd ~/dotfiles
nix flake update
sudo darwin-rebuild switch --flake .#RyosukenoMacBook-Pro
```

### 🐢 Nushell の場合

```nu
cd ~/dotfiles
nix flake update
sudo darwin-rebuild switch --flake .#RyosukenoMacBook-Pro
```

---

## 🧹 6. 不要なキャッシュ・過去世代の削除 (Clean up)

削除（アンインストール）したパッケージの残存データや、過去世代のバックアップを消去してストレージ容量を解放します。

### 🐚 zsh / 🐢 Nushell 共通

```bash
# 30日以上前の旧世代キャッシュを全削除
nix-collect-garbage --delete-older-than 30d

# すべての過去世代を即時削除
sudo nix-collect-garbage -d
```
