# 新しい Mac で開発環境をセットアップする手順 (Nix + nix-darwin + Home Manager)

このドキュメントでは、`nix-darwin` と `home-manager` を使用して dotfiles および全パッケージ環境を宣言的に一括構築・運用する手順を説明する。

dotfiles リポジトリ: `git@github.com:RyosukeNAKATA/dotfiles.git`

---

## 前提条件

- macOS (Apple Silicon / arm64)
- インターネット接続

---

## 1. Xcode Command Line Tools のインストール

```bash
xcode-select --install
```

---

## 2. Nix のインストール

 Determinate Systems の Nix インストーラー（推奨・Flakes 有効化済み）を実行：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://install.determinate.systems/nix | sh
```

※ もし Determinate インストーラーでエラーが出る場合は、Nix 公式マルチユーザーインストーラーを使用してください：

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

インストール後、ターミナルを再起動するか以下を実行して Nix 環境変数を読み込む：

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

---

## 3. SSH 鍵の生成と GitHub への登録（初時セットアップの場合）

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
```

---

## 4. dotfiles の取得と一括適用

### 4.1 dotfiles リポジトリの取得

```bash
git clone git@github.com:RyosukeNAKATA/dotfiles.git ~/dotfiles
```

### 4.2 Homebrew の初期インストール（未導入の場合）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 4.3 nix-darwin + Home Manager の適用

リポジトリディレクトリへ移動して管理者権限で構築コマンドを実行（sudo パスワードが要求されます）：

```bash
cd ~/dotfiles
sudo /nix/var/nix/profiles/default/bin/nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#RyosukenoMacBook-Pro
```

これにより以下が一括で自動処理されます：
1. **CLI / GUI パッケージの自動導入**: `darwin.nix` で宣言した Homebrew Casks (Alacritty, WezTerm, Raycast, Obsidian, Fonts 等) 及び Homebrew Formulae のインストール
2. **zsh プラグイン・環境のロード**: Home Manager による zsh 設定・`pure-prompt`, `zsh-autosuggestions`, `zsh-abbr`, `zsh-autopair` 等の完全自動生成
3. **Out-of-Store Symlink の配置**: `config/` 内の各ドットファイル（nvim, tmux, starship, yazi, zed 等）のシンボリックリンク化
4. **Neovim (dpp.vim) 必須リポジトリの自動クローン**: `home.activation.setupDpp` による初期化

---

## 5. 日常の運用・設定更新コマンド

### 設定変更の反映（`flake.nix` / `darwin.nix` / `home.nix` の追加・変更時）

```bash
sudo darwin-rebuild switch --flake ~/dotfiles#RyosukenoMacBook-Pro
```

### パッケージのアップデート

```bash
cd ~/dotfiles
nix flake update
sudo darwin-rebuild switch --flake .#RyosukenoMacBook-Pro
```
