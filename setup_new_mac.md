# 新しい Mac で開発環境をセットアップする手順

このドキュメントでは、chezmoi で管理している dotfiles を新しい Mac に展開し、開発環境を一括構築する手順を説明する。

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

インストール後、現在のシェルに PATH を通す:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## 3. SSH 鍵の生成と GitHub への登録

chezmoi で private リポジトリ（`git@github.com:...`）を取得する前に、GitHub への SSH 接続を準備する。

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

> **Note (テンプレート・環境分岐について):**  
> 一部の設定（`Brewfile` や `.zshrc` 等）では `.chezmoi.username` 等のテンプレート変数による環境分岐（仕事用/個人用など）が含まれています。必要に応じて `chezmoi init` 時に自動生成される設定や変数を指定・確認してください。

### 4.2 適用される変更を確認

```bash
chezmoi diff
```

### 4.3 dotfiles の適用（パッケージ・依存環境の自動インストール）

```bash
chezmoi apply
```

`chezmoi apply` を実行すると、設定ファイルの展開に加えて以下の自動処理（chezmoi スクリプト）が実行されます：
1. **`Brewfile` の自動適用 (`run_onchange_after_install-packages.sh.tmpl`)**:  
   Brewfile 内の全 CLI/GUI パッケージ、zsh プラグイン、フォントを一括インストールします。
2. **Neovim (dpp.vim) 必須リポジトリの自動クローン (`run_once_setup-dpp.sh`)**:  
   `~/.cache/dpp/repos/...` に dpp.vim, denops.vim 等の起動必須リポジトリを自動取得します。
3. **Copilot statusline 設定の適用 (`run_onchange_after_configure-copilot-statusline.sh`)**:  
   GitHub Copilot CLI の statusline 構成を適用します。

### 4.4 展開される主な設定・ファイル一覧

| 展開先 | 内容 |
|---|---|
| `~/.zshrc` | zsh 設定（mise, zoxide, starship, aliases 等） |
| `~/.tmux.conf` | tmux 設定 |
| `~/.config/nvim/` | Neovim 設定（dpp.vim, LSP, treesitter 等） |
| `~/.config/sheldon/` | sheldon (zsh プラグインマネージャ) 設定 |
| `~/.config/starship.toml` | Starship プロンプト設定 |
| `~/.config/alacritty/` | Alacritty ターミナル設定 |
| `~/.config/wezterm/` | WezTerm ターミナル設定 |
| `~/.config/git/` | Git 設定 |
| `~/.config/gitui/` | gitui 設定（キーバインド・テーマ） |
| `~/.config/yazi/` | yazi ファイルマネージャ設定 |
| `~/.config/zed/` | Zed エディタ設定 |
| `~/.config/gwq/` | gwq 設定 |
| `~/.config/neofetch/` | neofetch 設定 |
| `~/.config/nushell/` | Nushell 設定 |
| `~/.copilot/` | GitHub Copilot CLI 設定 |
| `~/.gemini/` | Antigravity / Gemini CLI ルール・カスタマイズ設定 |
| `~/.claude/` | Claude Code 設定 |
| `~/Brewfile` | Homebrew Bundle パッケージ定義 |

---

## 5. Neovim (dpp.vim) プラグインのインストール

`chezmoi apply` によって dpp.vim の必須スクリプトが展開済みのため、Neovim を起動してプラグインの一括インストールを実行するだけで完了します。

### 5.1 Neovim を起動してプラグインをインストール

```bash
nvim
```

起動後、Neovim 内でコマンドを実行:

```vim
:call dpp#async_ext_action('installer', 'install')
```

### 5.2 プラグインのアップデート（任意・日常運用）

```vim
:call dpp#async_ext_action('installer', 'update')
```

---

## 6. シェルの再読み込み

セットアップ完了後、シェルを再起動して新しい環境を読み込む:

```bash
exec zsh -l
```

`sheldon` が管理する zsh プラグイン（`zsh-autosuggestions`, `zsh-abbr`, `zsh-autopair`, `zsh-completions`, `pure`, `fast-syntax-highlighting`）や `mise`, `zoxide`, `starship` が自動ロードされます。

---

## 7. 動作確認チェックリスト

- [ ] `brew doctor` がエラーなく完了する
- [ ] `nvim` が起動し、`:call dpp#async_ext_action('installer', 'install')` でプラグインが正常に導入できる
- [ ] `tmux` が正常に起動する
- [ ] `starship` プロンプトが表示される
- [ ] `eza`, `bat`, `fd`, `rg` コマンドが使える
- [ ] `zoxide` (`z` コマンド) が動作する
- [ ] `mise` で言語環境が管理できる
- [ ] `sheldon` プラグインが正しく読み込まれている
- [ ] `gitui` が起動する
- [ ] `yazi` が起動する

---

## 8. dotfiles の更新・日常運用

### リモートの変更をローカルに取り込む

```bash
chezmoi update
```

### ローカルでの設定変更を chezmoi に反映・送信する

```bash
chezmoi re-add        # 変更したファイルを chezmoi 管理ソースに反映
chezmoi cd            # chezmoi ソースディレクトリへ移動
git add -A && git commit -m "update dotfiles" && git push
```

---

## トラブルシューティング

### chezmoi apply で brew bundle が失敗する場合

個別にパッケージをインストールするか、直接 `brew bundle` を実行してエラーログを確認してください:

```bash
brew bundle --file=~/Brewfile
```

### sheldon source でエラーが出る場合

sheldon のプラグインキャッシュを更新・クリアしてください:

```bash
sheldon lock --update
```

### dpp.vim のプラグインが読み込まれない場合

state ファイルをクリアして再構築してください:

```bash
rm -rf ~/.cache/dpp/state_*
nvim  # 再起動により dpp の make_state が自動実行されます
```
