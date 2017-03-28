execute pathogen#infect()
set autowrite
set incsearch 
set shiftwidth=4
set softtabstop=4
set smartcase
set hlsearch
set ruler
set showcmd
set wildmenu
set showmode
set nu
set nowrapscan
set number
set history=5000
set laststatus=2
set backspace=indent,eol,start
filetype on
filetype plugin on
filetype plugin indent on
autocmd FileType c setlocal textwidth=80
autocmd FileType cpp setlocal textwidth=80
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p
syntax enable
colorscheme desert
"colorscheme jellybeans
set background=dark
set guifont=Monospace\ 10
if has("gui_running")
    set guioptions -=T
    set guioptions +=e
    set t_Co=256
    set guitablabel=%M\ %t
endif
set t_Co=256
set omnifunc=syntaxcomplete#Complete
highlight ColorColumn ctermbg=magenta
call matchadd('colorcolumn','\%80v',100)
behave mswin
"if v:version > 700
"    set cursorline
"    hi CursorLine ctermbg = grey guibg = #F5FBF6
"endif
" if (&t_Co == 256 || &t_Co == 88) && !has('gui_running') &&
"	\ filereadable(expand("$HOME/.vim/plugin/guicolorscheme.vim"))
"	   runtime! plugin/guicolorscheme.vim
"endif

highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=Black guibg=#589A5D
