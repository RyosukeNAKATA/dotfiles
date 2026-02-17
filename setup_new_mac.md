# 新しい Mac で開発環境をセットアップする手順

このドキュメントでは、chezmoi で管理している dotfiles を新しい Mac に展開し、開発環境を構築する手順を説明する。

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

ダイアログが表示されたら「インストール」を選択して完了を待つ。

---

## 2. Homebrew のインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

インストール後、シェルに PATH を通す:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## 3. SSH 鍵の生成と GitHub への登録

chezmoi でリポジトリを取得する前に、GitHub への SSH 接続を準備する。

### 3.1 SSH 鍵を生成

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 3.2 公開鍵を GitHub に登録

公開鍵をクリップボードにコピー:

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

GitHub の **Settings > SSH and GPG keys > New SSH key** に貼り付けて登録する。

### 3.3 接続確認

```bash
ssh -T git@github.com
```

`Hi RyosukeNAKATA! You've successfully authenticated...` と表示されれば成功。

---

## 4. chezmoi のインストールと dotfiles の適用

### 4.1 chezmoi をインストールして dotfiles を取得

```bash
brew install chezmoi
chezmoi init git@github.com:RyosukeNAKATA/dotfiles.git
```

### 4.2 適用される内容を確認

```bash
chezmoi diff
```

### 4.3 dotfiles を適用

```bash
chezmoi apply
```

これにより以下のファイル/ディレクトリが `$HOME` 以下に展開される:

| 展開先 | 内容 |
|---|---|
| `~/.zshrc` | zsh 設定（テンプレート） |
| `~/.tmux.conf` | tmux 設定（iceberg テーマ） |
| `~/.config/nvim/` | Neovim 設定（dpp.vim, LSP, treesitter 等） |
| `~/.config/sheldon/` | sheldon (zsh プラグインマネージャ) 設定 |
| `~/.config/starship.toml` | Starship プロンプト設定 |
| `~/.config/alacritty/` | Alacritty ターミナル設定 |
| `~/.config/ghostty/` | Ghostty ターミナル設定 |
| `~/.config/wezterm/` | WezTerm ターミナル設定 |
| `~/.config/git/` | Git 設定 |
| `~/.config/gitui/` | gitui 設定（キーバインド・テーマ） |
| `~/.config/yazi/` | yazi ファイルマネージャ設定 |
| `~/.config/zed/` | Zed エディタ設定 |
| `~/.config/gwq/` | gwq 設定 |
| `~/.config/neofetch/` | neofetch 設定 |
| `~/Brewfile` | Homebrew Bundle 定義 |

---

## 5. Homebrew Bundle で一括インストール

chezmoi で展開された `~/Brewfile` を使ってパッケージを一括インストールする:

```bash
brew bundle --file=~/Brewfile
```

### 主なインストール対象

**CLI ツール:**
chezmoi, neovim, tmux, fzf, starship, deno, go, lua, luajit, cmake, gcc, jq, jql, wget, awscli, alp, imagemagick, mysql, postgresql@14, poetry, tree-sitter, neofetch, glow

**zsh プラグイン (brew 経由):**
zsh-autosuggestions, zsh-completions, zsh-fast-syntax-highlighting, zsh-autopair, zsh-abbr

**GUI アプリ (cask):**
Alacritty, WezTerm, Visual Studio Code, Raycast, AppCleaner, Obsidian

**フォント:**
Fira Code, HackGen Nerd

---

## 6. 追加ツールのインストール

Brewfile に含まれない追加ツールを手動でインストールする。

### 6.1 Rust / Cargo

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### 6.2 mise (ランタイムバージョンマネージャ)

```bash
curl https://mise.run | sh
```

> `.zshrc` 内で `eval "$(mise activate zsh)"` が設定済み。

### 6.3 sheldon (zsh プラグインマネージャ)

```bash
cargo install sheldon
```

または:

```bash
brew install sheldon
```

### 6.4 zoxide

```bash
brew install zoxide
```

> `.zshrc` 内で `eval "$(zoxide init zsh)"` が設定済み。

### 6.5 Rust 製 CLI ツール

`.zshrc` のエイリアスで使用しているツール:

```bash
cargo install eza bat fd-find ripgrep
```

または brew 経由:

```bash
brew install eza bat fd ripgrep
```

### 6.6 gitui

```bash
brew install gitui
```

### 6.7 yazi

```bash
brew install yazi
```

---

## 7. Neovim (dpp.vim) のセットアップ

Neovim のプラグイン管理に dpp.vim (Deno 製) を使用している。

### 7.1 dpp.vim の依存リポジトリをクローン

```bash
mkdir -p ~/.cache/dpp/repos/github.com/Shougo
mkdir -p ~/.cache/dpp/repos/github.com/vim-denops

cd ~/.cache/dpp/repos/github.com/Shougo
git clone git@github.com:Shougo/dpp.vim.git
git clone git@github.com:Shougo/dpp-ext-installer.git
git clone git@github.com:Shougo/dpp-protocol-git.git
git clone git@github.com:Shougo/dpp-ext-lazy.git
git clone git@github.com:Shougo/dpp-ext-toml.git

cd ~/.cache/dpp/repos/github.com/vim-denops
git clone git@github.com:vim-denops/denops.vim.git
```

### 7.2 Neovim を起動してプラグインをインストール

```bash
nvim
```

初回起動時に dpp が state を構築する。完了後、Neovim 内でプラグインをインストール:

```vim
:call dpp#async_ext_action('installer', 'install')
```

### 7.3 プラグインのアップデート（任意）

```vim
:call dpp#async_ext_action('installer', 'update')
```

---

## 8. シェルの再読み込み

すべてのインストールが完了したら、シェルを再起動する:

```bash
exec zsh -l
```

sheldon が管理する zsh プラグインが自動的にロードされる:
- zsh-autosuggestions
- zsh-abbr
- zsh-autopair
- zsh-completions
- pure (プロンプトテーマ)
- fast-syntax-highlighting

---

## 9. 動作確認チェックリスト

- [ ] `brew doctor` がエラーなく完了する
- [ ] `nvim` が起動し、プラグインが読み込まれる
- [ ] `tmux` が起動し、iceberg テーマが適用される
- [ ] `starship` プロンプトが表示される
- [ ] `fzf` のキーバインド（Ctrl+R: 履歴検索, Ctrl+T: ファイル検索）が動作する
- [ ] `eza`, `bat`, `fd`, `rg` コマンドが使える
- [ ] `zoxide` (`z` コマンド) が動作する
- [ ] `mise` でランタイムバージョンが管理できる
- [ ] `gitui` が起動する
- [ ] `yazi` が起動する

---

## 10. dotfiles の更新・同期

### リモートの変更を取り込む

```bash
chezmoi update
```

### ローカルの変更をリポジトリに反映する

```bash
chezmoi re-add        # 変更されたファイルを chezmoi に反映
chezmoi cd            # chezmoi ソースディレクトリへ移動
git add -A && git commit -m "update dotfiles" && git push
```

---

## トラブルシューティング

### sheldon source でエラーが出る

sheldon のプラグインキャッシュをクリアして再構築:

```bash
sheldon lock --update
```

### dpp.vim のプラグインが読み込まれない

state ファイルを削除して再構築:

```bash
rm -rf ~/.cache/dpp/state_*
nvim  # 再起動で自動的に make_state が実行される
```

### Brewfile の適用でエラーが出る

個別にインストールを試す:

```bash
brew install <パッケージ名>
```

廃止された tap (`homebrew/core`, `homebrew/cask` 等) に関する警告は、Homebrew 4.x 以降では無視して問題ない。
