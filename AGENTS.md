# AGENTS.md

AI エージェント（Claude Code, Codex 等）向けの作業ガイド。`CLAUDE.md` を補完する。

このリポジトリは個人の dotfiles（Neovim / zsh / Ghostty / Vim）。配置・ビルド・規則の詳細は `CLAUDE.md` を参照する。

## 必ず守ること

- **可搬性**: `/Users/<name>/...` などマシン固有の直書きを絶対にコミットしない。`$HOME` 等に変数化する。コミット前に `rg -n "/Users/|/home/[a-z]" -g '!.git' .` で確認する。
- **秘匿値を入れない**: PUBLIC リポジトリ。トークン・鍵を置かない。
- **バイナリを置かない**: `afm` などのコンパイル成果物はコミットせず、ソース（`afm.swift`）だけ置く。
- **同期**: ローカルの実ファイル（`~/.config/nvim/init.lua` 等）を変更したら、対応する repo 内ファイルと README・CLAUDE.md の構成表も合わせて更新する。

## よく使う操作

```sh
swiftc -O nvim/afm.swift -o ~/.local/bin/afm   # afm をビルド
rg -n "/Users/|/home/[a-z]" -g '!.git' .       # 直書きパス検査
```
