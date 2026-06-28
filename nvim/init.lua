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
      local api = require("nvim-tree.api")

      -- 右クリックメニューの「ブラウザ系」項目から呼ぶヘルパ。
      -- いずれもカーソル直下のノード（右クリックした行）を対象にする。
      _G.TreeBrowser = {
        -- 静的に既定ブラウザで開く（file://、サーバ不要・どんなファイルでも開ける）
        open = function()
          local node = api.tree.get_node_under_cursor()
          if node and node.absolute_path then
            vim.ui.open(node.absolute_path)
          end
        end,
        -- live-preview サーバで開く（HTML / Markdown 等を自動リロード付きで表示）
        live = function()
          local node = api.tree.get_node_under_cursor()
          if node and node.absolute_path then
            vim.cmd("LivePreview start " .. vim.fn.fnameescape(node.absolute_path))
          end
        end,
      }

      -- 右クリックメニュー本体（マウスでクリックして選べるネイティブ popup）。
      -- ラベルは日本語。"." はサブメニュー区切りなので各項目をベタ書きする。
      -- 既定キー(d=削除 / r=リネーム)はそのまま残るので、キーボードでも操作できる。
      vim.cmd([[
        silent! aunmenu TreeCtx
        nnoremenu TreeCtx.開く            <Cmd>lua require('nvim-tree.api').node.open.edit()<CR>
        nnoremenu TreeCtx.ブラウザで開く  <Cmd>lua _G.TreeBrowser.open()<CR>
        nnoremenu TreeCtx.ライブプレビュー <Cmd>lua _G.TreeBrowser.live()<CR>
        nnoremenu TreeCtx.-sep1-          <Nop>
        nnoremenu TreeCtx.リネーム        <Cmd>lua require('nvim-tree.api').fs.rename()<CR>
        nnoremenu TreeCtx.削除            <Cmd>lua require('nvim-tree.api').fs.remove()<CR>
        nnoremenu TreeCtx.-sep2-          <Nop>
        nnoremenu TreeCtx.新規作成        <Cmd>lua require('nvim-tree.api').fs.create()<CR>
        nnoremenu TreeCtx.切り取り        <Cmd>lua require('nvim-tree.api').fs.cut()<CR>
        nnoremenu TreeCtx.コピー          <Cmd>lua require('nvim-tree.api').fs.copy.node()<CR>
        nnoremenu TreeCtx.貼り付け        <Cmd>lua require('nvim-tree.api').fs.paste()<CR>
      ]])

      require("nvim-tree").setup({
        view = { width = 32 },
        renderer = { group_empty = true },
        filters = { dotfiles = false }, -- ドットファイルも表示
        on_attach = function(bufnr)
          -- 既定のキー操作（d=削除 / r=リネーム / a=新規 など）はそのまま残す
          api.config.mappings.default_on_attach(bufnr)
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end
          -- 押した瞬間にクリック位置の行へカーソルを移動する
          vim.keymap.set("n", "<RightMouse>", function()
            local m = vim.fn.getmousepos()
            if m.winid ~= 0 and m.line and m.line > 0 then
              pcall(vim.api.nvim_set_current_win, m.winid)
              pcall(vim.api.nvim_win_set_cursor, m.winid, { m.line, 0 })
            end
          end, opts("右クリック位置へカーソル移動"))
          -- ボタンを離したらカーソル直下のノードに対してメニューを開く
          vim.keymap.set("n", "<RightRelease>", function()
            if api.tree.get_node_under_cursor() then
              vim.cmd("popup TreeCtx")
            end
          end, opts("右クリックメニュー（削除 / リネーム ほか）"))
        end,
      })
    end,
  },

  -- ファジーファインダ（ファイル名検索・全文検索）
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          -- 検索窓を開いている間のキー。覚える数を減らすため hjkl 寄せ。
          -- 迷ったら検索窓で <C-/> を押すと、その場で全キー一覧が出る（覚えなくていい）。
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next, -- 次の候補へ
              ["<C-k>"] = actions.move_selection_previous, -- 前の候補へ
              ["<C-v>"] = actions.select_vertical, -- 右に縦分割で開く
              ["<C-x>"] = actions.select_horizontal, -- 下に横分割で開く
              ["<C-t>"] = actions.select_tab, -- 新しいタブで開く
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist, -- 全件をまとめて開く(quickfix)
              ["<Esc>"] = actions.close, -- Esc 一発で閉じる
            },
          },
        },
      })
    end,
  },

  -- Space を押すと「今押せる操作の一覧」をメニュー表示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 100, -- Space を押してからメニューが出るまで(ミリ秒)。短いほど「覚えなくていい」
      preset = "modern",
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- グループ名（サブメニューの見出し）を登録
      wk.add({
        { "<leader>f", group = "検索" },
        { "<leader>w", group = "ウィンドウ" },
        { "<leader>c", group = "Claude" },
      })
    end,
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

  -- クリップボードの画像を貼り付け（ファイルに保存し、その場へリンクを挿入）。
  -- macOS では pngpaste が必須（brew install pngpaste）。スクショ等をコピーしてから
  -- 本文の入れたい位置で <leader>p（Space p）。Markdown なら ![]() が入る。
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "assets", -- 画像の保存先フォルダ（なければ自動作成）
        relative_to_current_file = true, -- 編集中ファイルと同じ場所の assets/ に置く
        prompt_for_file_name = true, -- 保存名を聞く（空 Enter で日時名）
        insert_mode_after_paste = false, -- 貼り付け後はノーマルモードのまま
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "画像をクリップボードから貼り付け" },
    },
  },

  -- Claude Code 一体化
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude-code").setup({
        window = {
          position = "float", -- 画面中央にフローティング表示（分割せずレイアウトを邪魔しない）
          enter_insert = true, -- 開いたら即入力モード
          float = {
            width = "85%",
            height = "85%",
            row = "center",
            col = "center",
            relative = "editor",
            border = "rounded",
          },
        },
        git = { use_git_root = true }, -- git リポジトリのルートで起動
        command = "claude",
      })
    end,
  },

  -- annai.nvim（自作・公開済み）: Space ? で「やりたいこと」を日本語で聞くと、
  -- 自分の keymap から該当キーを案内。履歴 ON で :Annai stats が「よく聞く操作
  -- （まだ覚えてないキー）」を炙り出す。端末内のみ・:Annai history clear で消去。
  -- ローカルに開発用クローンがあればそれを使い、無ければ公開版を GitHub から取得する
  -- （フレッシュマシンでもそのまま動くよう、直書きのホームパスは使わない）。
  {
    "susumutomita/annai.nvim",
    dir = (vim.fn.isdirectory(vim.fn.expand("~/product/annai.nvim")) == 1)
        and vim.fn.expand("~/product/annai.nvim")
      or nil,
    event = "VeryLazy",
    opts = {
      -- 実用速度優先: afm(Apple, 常駐でコールド始動なし)を先に使う（これが既定の順番）。
      -- 弱点: 一覧に無い操作だと afm は無理に1つ選ぶ（置換→無関係キー）。
      --   該当なしの誤答が気になる時だけ backends = { "ollama", "afm" } に変える。
      ollama = { model = "qwen2.5:3b" }, -- afm 不在/フォールバック時に使用（no-match も正しい）
      history = { enabled = true },
      keymap = "<F1>", -- 起動キー。leader を避けて which-key メニューを挟まない。エスカレーションも F1 連打
    },
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
-- 「覚えていない」ときの保険。Space f k で全ショートカットを検索できる
map("n", "<leader>fk", function()
  require("telescope.builtin").keymaps()
end, { desc = "ショートカット一覧を検索" })
map("n", "<leader>fr", function()
  require("telescope.builtin").resume()
end, { desc = "前回の検索を再開" })
map("n", "<leader>fl", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "このファイル内を検索" })

-- ウィンドウ間移動。ファイラー(左)⇄本文(右)はこの 2 つで往復する。
--   <C-h> = 左の窓へ（本文 → ファイラー） / <C-l> = 右の窓へ（ファイラー → 本文）
-- ※ nvim-tree は <C-k> を別用途で使うので、ツリー内で「上の窓へ」は効かない（左右で十分）
map("n", "<C-h>", "<C-w>h", { desc = "左の窓へ（本文→ファイラー）" })
map("n", "<C-j>", "<C-w>j", { desc = "下の窓へ" })
map("n", "<C-k>", "<C-w>k", { desc = "上の窓へ" })
map("n", "<C-l>", "<C-w>l", { desc = "右の窓へ（ファイラー→本文）" })

-- 同じ窓移動を <leader>w にも置く。Space を押せば which-key と Space? ガイドに出る＝覚えなくていい
map("n", "<leader>wh", "<C-w>h", { desc = "左の窓へ（ファイラー）" })
map("n", "<leader>wj", "<C-w>j", { desc = "下の窓へ" })
map("n", "<leader>wk", "<C-w>k", { desc = "上の窓へ" })
map("n", "<leader>wl", "<C-w>l", { desc = "右の窓へ（本文）" })

-- Claude Code は Ctrl-, が標準。効かない端末向けに leader+cc でも開ける保険
map("n", "<leader>cc", "<cmd>ClaudeCode<CR>", { desc = "Claude Code 開閉" })

-- ブラウザでライブプレビュー（Markdown / HTML）。v = view
map("n", "<leader>v", "<cmd>LivePreview start<CR>", { desc = "ブラウザでプレビュー開始" })
map("n", "<leader>V", "<cmd>LivePreview close<CR>", { desc = "プレビュー停止" })

-- annai は F1 が主。忘れた時用に Space → ? でも見つかるよう which-key に載せる（押せば起動）
map("n", "<leader>?", function()
  require("annai").ask()
end, { desc = "案内 annai（F1 でも可）" })
