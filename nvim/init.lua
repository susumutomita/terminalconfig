-- ~/.config/nvim/init.lua
-- キーボードだけで開発が完結する Neovim 設定。
-- 旧 ~/.vimrc の好みを引き継ぎつつ、Claude Code / ファイルツリー / 検索を統合する。

--------------------------------------------------------------------------------
-- 0. リーダーキー（プラグイン読み込み前に設定する必要がある）
--------------------------------------------------------------------------------
vim.g.mapleader = " " -- <leader> をスペースキーに割り当てる
vim.g.maplocalleader = " "

-- nvim-tree を使うので標準ファイラ netrw は無効化する
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--------------------------------------------------------------------------------
-- 1. 基本設定（旧 .vimrc から引き継ぎ）
--------------------------------------------------------------------------------
local opt = vim.opt

opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backup = false -- バックアップファイルを作らない
opt.swapfile = false -- スワップファイルを作らない
opt.autoread = true -- 外部で変更されたら自動で読み直す
opt.hidden = true -- 未保存でも他のファイルを開ける
opt.showcmd = true -- 入力中のコマンドを表示

opt.number = true -- 行番号を表示
opt.cursorline = true -- 現在の行を強調
opt.virtualedit = "onemore" -- 行末の 1 文字先までカーソルを移動できる
opt.smartindent = true -- スマートインデント
opt.visualbell = true -- ビープ音を可視化
opt.showmatch = true -- 対応する括弧を表示
opt.laststatus = 3 -- ステータスラインを常に表示（全体で 1 本）
opt.wildmode = "list:longest" -- コマンドライン補完

opt.expandtab = true -- タブをスペースに変換
opt.tabstop = 2 -- タブの表示幅
opt.shiftwidth = 2 -- インデント幅
opt.list = true
-- 余分な空白を可視化（タブ・末尾空白・全角ではない特殊空白・行外文字）
opt.listchars = {
  tab = "▸-", -- タブ
  trail = "·", -- 行末の余分な空白
  nbsp = "␣", -- ノーブレークスペース
  extends = "»", -- 折り返しオフ時に画面右へ続くマーク
  precedes = "«", -- 画面左へ続くマーク
}

opt.ignorecase = true -- 検索で大文字小文字を区別しない
opt.smartcase = true -- 大文字を含むときだけ区別する
opt.incsearch = true -- インクリメンタル検索
opt.wrapscan = true -- 末尾で先頭へ折り返す
opt.hlsearch = true -- 検索語をハイライト

opt.termguicolors = true -- 24bit カラー（配色をきれいに表示）
opt.clipboard = "unnamedplus" -- OS のクリップボードと共有（yank/paste が連動）

-- 折り返した行でも表示行単位で j/k 移動する
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
-- Esc を 2 回で検索ハイライトを解除
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>")

--------------------------------------------------------------------------------
-- 2. lazy.nvim（プラグインマネージャ）を自動セットアップ
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- 3. プラグイン
--------------------------------------------------------------------------------
require("lazy").setup({
  -- 配色（旧 .vimrc と同じ hybrid）
  {
    "w0ng/vim-hybrid",
    priority = 1000, -- 配色は最優先で読み込む
    config = function()
      vim.cmd.colorscheme("hybrid")
    end,
  },

  -- アイコン（Nerd Font が必要）
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ファイルツリー（VSCode 風サイドバー）
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 32 },
        renderer = { group_empty = true },
        filters = { dotfiles = false }, -- ドットファイルも表示
      })
    end,
  },

  -- ファジーファインダ（ファイル名検索・全文検索）
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- 保存時の自動フォーマット & 末尾空白の自動トリム
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- 保存直前に読み込む
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        -- コードは各フォーマッタで整形（biome は node_modules/.bin も自動探索）
        lua = { "stylua" },
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        -- 上記以外（markdown / text など）は末尾空白と余分な空行だけ削除
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
    },
  },

  -- ブラウザでライブプレビュー（Markdown / HTML / CSS / SVG）
  {
    "brianhuster/live-preview.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("livepreview.config").set()
    end,
  },

  -- Claude Code 一体化
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude-code").setup({
        window = {
          position = "vertical", -- 右側に縦分割で開く（VSCode の AI パネル風）
          split_ratio = 0.4, -- 画面の 40% 幅
          enter_insert = true, -- 開いたら即入力モード
        },
        git = { use_git_root = true }, -- git リポジトリのルートで起動
        command = "claude",
      })
    end,
  },
})

--------------------------------------------------------------------------------
-- 4. キーマップ（プラグイン操作）
--------------------------------------------------------------------------------
local map = vim.keymap.set

-- ファイルツリーの開閉
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "ファイルツリー開閉" })

-- Telescope（検索）。require は遅延させて読み込み順の問題を避ける
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "ファイル名で検索" })
map("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "全文検索" })
map("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "開いているバッファ一覧" })
map("n", "<leader>fh", function()
  require("telescope.builtin").help_tags()
end, { desc = "ヘルプ検索" })

-- ウィンドウ間移動（Ctrl + h/j/k/l で左下上右へ）
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Claude Code は Ctrl-, が標準。効かない端末向けに leader+cc でも開ける保険
map("n", "<leader>cc", "<cmd>ClaudeCode<CR>", { desc = "Claude Code 開閉" })

-- ブラウザでライブプレビュー（Markdown / HTML）。v = view
map("n", "<leader>v", "<cmd>LivePreview start<CR>", { desc = "ブラウザでプレビュー開始" })
map("n", "<leader>V", "<cmd>LivePreview close<CR>", { desc = "プレビュー停止" })
