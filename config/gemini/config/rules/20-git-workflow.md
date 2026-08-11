# Git & Workflow Guidelines (20-git-workflow.md)

## 1. コミット規約
- **ユーザーから明示的な指示がない限り、`git commit` や `git push` 等のコミット・送信操作を自発的に行わないこと。**
- 指示を受けてコミットを行う際は、変更理由と概要を分かりやすく明確に記述すること。
- Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`) 形式を推奨する。

## 2. 作業範囲の限定
- ユーザーに要求された範囲外のファイルをみだりに変更しないこと。
- 一時ファイルやテスト用のスクリプトは適切な場所（.gitignore対象や規定のスクリプト用ディレクトリ）に配置すること。
