" 基本設定
set fenc=utf-8            " 文字コードをUTF-8に設定
set nobackup              " バックアップファイルを作らない
set noswapfile            " スワップファイルを作らない
set autoread              " 編集中のファイルが変更されたら自動で読み直す
set hidden                " バッファが編集中でも他のファイルを開ける
set showcmd               " 入力中のコマンドをステータスに表示

" 見た目系
set number                " 行番号を表示
set cursorline            " 現在の行を強調表示
set cursorcolumn          " 現在の列を強調表示
set virtualedit=onemore   " 行末の1文字先までカーソルを移動
set smartindent           " スマートインデント
set visualbell            " ビープ音を可視化
set showmatch             " 括弧の対応を表示
set laststatus=2          " ステータスラインを常に表示
set wildmode=list:longest " コマンドライン補完の設定

" 折り返し時のカーソル移動
nnoremap j gj
nnoremap k gk

" タブとスペース
set list listchars=tab:\▸\-
set expandtab             " タブをスペースに変換
set tabstop=2             " タブの表示幅
set shiftwidth=2          " シフト幅

" 検索系
set ignorecase            " 大文字小文字を区別しない検索
set smartcase             " 検索文字に大文字が含まれていれば区別
set incsearch             " インクリメンタル検索
set wrapscan              " 検索がファイル末尾で折り返す
set hlsearch              " 検索語をハイライト表示

" ハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" カラースキーム
let g:hybrid_use_iTerm_colors = 1
colorscheme hybrid
syntax on

" 行番号の色設定
set cursorline
hi clear CursorLine
