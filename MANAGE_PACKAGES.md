# パッケージ・アプリの追加・削除・バージョンアップ（管理手順書）

Nix + nix-darwin + Home Manager 環境において、CLI パッケージ・GUI アプリ（Cask）・zsh プラグイン・言語ランタイム・各種ツールの**追加（インストール）**、**削除（アンインストール）**、および**バージョンアップ（更新）**を行う手順を解説します。

---

## 💡 基本の流れ

1. リポジトリ内の定義ファイル（`darwin.nix` または `home.nix`）を編集する
2. 変更を Git でトラックする (`git add .`)
3. 構築反映コマンドを実行する (`sudo darwin-rebuild switch ...`)

---

## 1. GUI アプリ（Cask）やフォントの追加・削除

Mac の GUI アプリ（Raycast, Obsidian, WezTerm 等）やフォントは [`darwin.nix`](darwin.nix) の `homebrew.casks` で管理します。

### 追加する手順
[`darwin.nix`](darwin.nix) の `homebrew.casks` 配下にパッケージ名を追加します：

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

CLI パッケージ（`ripgrep`, `bat`, `eza`, `fzf` 等）は、[`darwin.nix`](darwin.nix) の `homebrew.brews` または [`home.nix`](home.nix) の `home.packages` で管理します。

### Homebrew 経由の CLI パッケージ追加・削除
[`darwin.nix`](darwin.nix) の `homebrew.brews` を編集：

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
[`home.nix`](home.nix) の `home.packages` を編集：

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

zsh プラグインは [`home.nix`](home.nix) の `programs.zsh.plugins` で管理します。

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

## 🔄 5. パッケージ・各ツールの更新 (Update)

本環境で管理・使用している各種ツールおよび設定のバージョンアップ手順一覧です。

### 5.1 Nixpkgs / nix-darwin / Home Manager（システム全体 & CLIツール）

[`flake.nix`](flake.nix) や [`home.nix`](home.nix) で管理しているパッケージ群（`pure-prompt`, `zsh-autopair` 等）および nix-darwin システム全体の更新手順です。

```zsh
cd ~/dotfiles

# 1. flake.lock を更新し最新のリビジョンを取得
nix flake update

# 2. 最新バージョンを反映・構築
sudo darwin-rebuild switch --flake .#RyosukenoMacBook-Pro
```

### 5.2 Homebrew（GUI アプリ / Cask & brew 公式パッケージ）

[`darwin.nix`](darwin.nix) の `homebrew.brews` および `homebrew.casks` で管理しているツール群です。
`darwin.nix` で `autoUpdate = true` および `upgrade = true` が有効になっているため、上記 **5.1** の **`sudo darwin-rebuild switch` 実行時に自動的に Homebrew のアップデート＆アップグレードが同時実行**されます。

即座に手動で更新したい場合：
```zsh
brew update && brew upgrade && brew upgrade --cask
```

### 5.3 mise（プログラミング言語・各種ランタイム）

`mise` 経由で管理している言語環境（Node.js, Python, Ruby, Go 等）の更新手順です。

```zsh
# インストール済みツールの更新状態を確認
mise outdated

# インストール済み全ツールを最新版にアップグレード
mise upgrade

# 特定ツール（例: Node.js）を最新安定版に指定して更新
mise use --global node@latest
```

### 5.4 Neovim プラグイン（dpp.vim & Mason.nvim）

[`config/nvim`](config/nvim) で管理している Neovim のプラグイン更新手順です。

#### A. dpp.vim プラグイン (`dpp.toml` で管理)
Neovim 起動中に以下を実行：
```vim
:call dpp#async_ext_action('installer', 'update')
```

#### B. Mason.nvim（LSP サーバー / Formatter / Linter）
Neovim 起動中に以下を実行：
```vim
:Mason
```
UI 画面上で `U` キーを押すと、インストール済み LSP / Linter 等が一括更新されます。（または `:MasonUpdate` コマンドを実行）

---

## 🧹 6. 不要なキャッシュ・過去世代の削除 (Clean up)

削除（アンインストール）したパッケージの残存データや、過去世代のバックアップを消去してストレージ容量を解放します。

### 🐚 zsh / 🐢 Nushell 共通

```bash
# 30日以上前の旧世代キャッシュを全削除
nix-collect-garbage --delete-older-than 30d

# すべての過去世代を即時削除
sudo nix-collect-garbage -d

# Homebrew の古いバージョンキャッシュを削除
brew cleanup
```

