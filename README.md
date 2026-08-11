# Ryosuke's Dotfiles (Nix + nix-darwin + Home Manager)

macOS 環境のパッケージ・ドットファイル・システム設定を Nix (`nix-darwin` + `home-manager`) で宣言的に一括管理するリポジトリです。

---

## 🚀 新しい Mac での初期セットアップ手順 (標準 zsh 対応)

macOS デフォルトのターミナル (`zsh`) を開き、以下の手順を順番に実行することで環境をゼロから一括構築できます。

### Step 1: Xcode Command Line Tools のインストール

```zsh
xcode-select --install
```
※ ダイアログが表示された場合は「インストール」をクリックして完了を待ちます。

---

### Step 2: Nix のインストール

Determinate Systems の Nix インストーラー（推奨）を実行します：

```zsh
curl --proto '=https' --tlsv1.2 -sSf https://install.determinate.systems/nix | sh
```

インストール完了後、環境変数を現在の zsh シェルに読み込みます：

```zsh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

---

### Step 3: Homebrew のインストール

macOS 用の GUI アプリ（Cask）やフォントを一括管理するため、Homebrew を導入します：

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

### Step 4: dotfiles リポジトリの取得

```zsh
mkdir -p ~
git clone git@github.com:RyosukeNAKATA/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### Step 5: nix-darwin + Home Manager の一括適用

以下のコマンドを実行してシステム設定・GUI アプリ・CLI パッケージ・ドットファイルのシンボリックリンクを一括構築します：

```zsh
sudo -E NIX_CONFIG="experimental-features = nix-command flakes" /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake .#RyosukenoMacBook-Pro
```

> **Note (初回エラー時の対処):**  
> 既存の `/etc/bashrc` と競合した場合は、以下を実行して退避させてから再度上記コマンドを実行してください：
> ```zsh
> sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin 2>/dev/null || true
> ```

---

## 🛠️ アプリ・パッケージの追加とアンインストール方法

環境構築後のアプリや CLI ツール、zsh プラグインの追加・削除（アンインストール）手順については、以下の専用手順書を参照してください：

📄 [**アプリ・パッケージ管理手順書 (MANAGE_PACKAGES.md)**](file:///Users/ryosuke/.local/share/chezmoi/MANAGE_PACKAGES.md)

---

## 🔄 日常の運用・設定更新

初回セットアップ完了後は `darwin-rebuild` コマンドがパスに通るため、以下のコマンドで手軽に設定の変更・反映を行えます。

### 設定の変更・追加を反映する (`flake.nix` / `darwin.nix` / `home.nix` 編集時)

```zsh
sudo darwin-rebuild switch --flake ~/dotfiles#RyosukenoMacBook-Pro
```

### パッケージ（Nix Inputs）のアップデート

```zsh
cd ~/dotfiles
nix flake update
sudo darwin-rebuild switch --flake .#RyosukenoMacBook-Pro
```

---

## 📁 ディレクトリ構造

```text
dotfiles/
├── flake.nix        # エントリーポイント（nix-darwin + home-manager 統合）
├── flake.lock       # パッケージバージョン固定
├── darwin.nix       # macOS システム設定 + Homebrew (Casks / Brews / Taps) 宣言的定義
├── home.nix         # Home Manager (CLI ツール / zsh 設定 & プラグイン / Out-of-Store Symlinks)
├── config/          # ドットファイル本体 (~/.config/ や Out-of-Store リンク配置)
│   ├── zsh/         # ~/.config/zsh/.zshrc -> dotfiles/config/zsh/.zshrc
│   ├── bash/        # ~/.bashrc, ~/.bash_profile -> dotfiles/config/bash/.bashrc
│   ├── nvim/        # Neovim 設定 (dpp.vim)
│   ├── tmux/        # tmux 設定
│   ├── starship.toml
│   ├── alacritty/
│   ├── wezterm/
│   ├── git/
│   ├── gitui/
│   ├── yazi/
│   └── ...
```
