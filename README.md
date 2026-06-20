# terminalconfig

ターミナルまわりの個人設定をまとめたリポジトリ。

## 構成

| パス | 内容 |
| --- | --- |
| `nvim/init.lua` | Neovim 設定（キーボードだけで開発が完結する構成） |
| `.vimrc` | Vim 設定 |
| `.zshrc` | zsh 設定（prompt pure / mise / bun / 補完 / エイリアス） |
| `config.fish` | fish 設定 |
| `wezterm/` | WezTerm 設定 |

## Neovim セットアップ

### 必要なもの

```sh
brew install neovim ripgrep fd
brew install --cask font-hack-nerd-font   # アイコン表示用。端末フォントに設定する
```

アイコンを正しく表示するため、ターミナル（Terminal.app / iTerm2 / WezTerm）のフォントを `Hack Nerd Font` に設定する。

### 配置

`nvim/init.lua` を `~/.config/nvim/init.lua` に置く。

```sh
mkdir -p ~/.config/nvim
ln -sf "$(pwd)/nvim/init.lua" ~/.config/nvim/init.lua
```

初回に `nvim` を起動すると lazy.nvim がプラグインを自動インストールする。

### 導入プラグイン

- lazy.nvim — プラグインマネージャ
- claude-code.nvim — Claude Code をエディタ内に統合
- nvim-tree — ファイルツリー
- telescope.nvim — ファイル名検索・全文検索
- which-key.nvim — `Space` を押すと押せる操作の一覧をメニュー表示
- conform.nvim — 保存時の自動フォーマットと末尾空白の削除
- live-preview.nvim — Markdown / HTML のブラウザライブプレビュー
- vim-hybrid — 配色

### キーバインド

リーダーキーはスペース。

| キー | 動作 |
| --- | --- |
| `Space`（押して待つ） | 押せる操作の一覧をメニュー表示（which-key） |
| `Space ?` | やりたいことをローカル LLM に聞く（後述） |
| `Space e` | ファイルツリー開閉 |
| `Space ff` | ファイル名で検索（VSCode の Cmd+P 相当） |
| `Space fg` | 全文検索（VSCode の Cmd+Shift+F 相当） |
| `Space fb` | 開いているバッファ一覧 |
| `Ctrl-,` / `Space cc` | Claude Code 開閉 |
| `Space v` | ブラウザでライブプレビュー開始 |
| `Space V` | ライブプレビュー停止 |
| `Ctrl-h` / `Ctrl-j` / `Ctrl-k` / `Ctrl-l` | ウィンドウ間移動（左 / 下 / 上 / 右） |
| `Esc Esc` | 検索ハイライト解除 |

保存（`:w`）すると、コードは Biome / Stylua で自動整形され、その他のファイルは末尾空白が自動削除される。

### ローカル LLM ガイド（`Space ?`）

`Space ?` で「やりたいこと」を自然言語で入力すると、ローカル LLM が現在の設定に実在するキーマップ（リーダー始まりの自作キー）だけから最も合う操作を選んで答える。回答は右下の非フォーカス窓に出るので操作を邪魔しない。

バックエンドは 2 段構え。

1. `afm`（Apple オンデバイス LLM / FoundationModels）を優先。クラウド送信なし・モデルのダウンロード不要。`nvim/afm.swift` をビルドして使う。

   ```sh
   swiftc -O nvim/afm.swift -o ~/.local/bin/afm
   ```

   要件は macOS 26 以降 + Apple Intelligence 有効 + 対応 Mac（Apple Silicon）。`~/.local/bin` が PATH に入っていること。コンパイル済みバイナリは環境依存のためコミットしない。

2. `afm` が無い環境では Ollama にフォールバックする。

   ```sh
   brew install --cask ollama
   ollama pull qwen2.5:3b   # init.lua の guide.model で変更可
   ```

どちらも使えない場合は `Space ?` がセットアップを促すメッセージを表示する。
