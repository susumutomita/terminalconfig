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

`Space ?` で「やりたいこと」を自然言語で入力すると、ローカル LLM が現在の設定に実在するキーマップだけを使って手順を答える。回答は右下の非フォーカス窓に出るので操作を邪魔しない。

セットアップ:

```sh
brew install --cask ollama   # または https://ollama.com からアプリを入れる
ollama pull qwen2.5:3b        # 使うモデル（init.lua の guide.model で変更可）
```

Ollama アプリ（サーバー）が起動している必要がある。停止中は `Space ?` が接続エラーを表示する。`localhost:11434` を使うため特定マシンに依存しない。
