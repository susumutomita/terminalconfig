# CLAUDE.md

個人のターミナル設定（dotfiles）リポジトリ。Neovim・zsh・Ghostty・Vim の設定を管理する。

## リポジトリ構成

| パス | 配置先 | 内容 |
| --- | --- | --- |
| `nvim/init.lua` | `~/.config/nvim/init.lua` | Neovim 設定（lazy.nvim ベース） |
| `nvim/afm.swift` | ビルドして `~/.local/bin/afm` | Apple オンデバイス LLM CLI のソース |
| `ghostty/config` | `~/.config/ghostty/config` | Ghostty 設定 |
| `.zshrc` | `~/.zshrc` | zsh 設定 |
| `.vimrc` | `~/.vimrc` | Vim 設定 |

配置はシンボリックリンク推奨（例: `ln -sf "$(pwd)/nvim/init.lua" ~/.config/nvim/init.lua`）。

## 最重要ルール: 可搬性

このリポジトリは PUBLIC かつ複数マシンで使う。**特定マシンでしか動かない設定をコミットしない。**

- ホームは `$HOME`、Homebrew prefix は `$(brew --prefix)` のように変数化する。`/Users/<name>/...` の直書きは禁止。
- コミット前に必ず確認する。

  ```sh
  rg -n "/Users/|/home/[a-z]" -g '!.git' .
  ```

- トークンや鍵などの秘匿値は置かない。マシン固有値が必要なら `~/.zshrc.local` 等の非追跡ファイルに分離する。
- コンパイル済みバイナリ（`afm` 等）は環境依存なのでコミットしない。ソースだけを置く。

## afm（Apple オンデバイス LLM）のビルド

```sh
swiftc -O nvim/afm.swift -o ~/.local/bin/afm
```

要件は macOS 26 以降 + Apple Intelligence 有効 + Apple Silicon。`~/.local/bin` が PATH に入っていること。

## ドキュメント・コミット規則

- 文末は「。」で終える。日本語と半角英数字の間に半角スペースを入れる。
- Conventional Commits 形式でコミットする。
- 設定ファイルを足す・消すときは、README と本ファイルの構成表も合わせて更新する。
