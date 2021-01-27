" setting
" 文字コードをutf8に設定
set encoding=utf-8
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読みなおす
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd
filetype plugin indent on
syntax on
" 見た目系
" 行番号を表示
set number
" 現在の行を強調表示
set cursorline
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" インデントはスマートインデント
set smartindent
" ビープ音は可視化
set visualbell
" 括弧入力時の対応する括弧を表示
set showmatch
" ステータスラインを常に表示
set laststatus=2
" コマンドラインの補完
set wildmode=list:longest
" 折り返し時に行単位での移動を可能にする
nnoremap j gj
nnoremap k gk
" tab系
" 不可視系文字を可視化
set list listchars=tab:»- ",trail:-,eol:↲,extends:»,precedes:«,nbsp:%
" Tab文字を半角スペースに
set expandtab
" 行頭以外のTab文字の表示幅(スペース数)
set tabstop=4
" 行頭でのTab文字の表示幅(スペース数)
set shiftwidth=4
" 検索系
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索
set smartcase
" 検索文字列入力時に順次対応文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch
" ESC 連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>
nmap <C-j> <esc>

set backspace=indent,eol,start
set clipboard=unnamed,autoselect

highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=22
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=52
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17
highlight DiffText   cterm=bold ctermfg=10 ctermbg=21
