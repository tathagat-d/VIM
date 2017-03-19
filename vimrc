"""""""""""""""""""""""""""""""""""""""
"Using pathogen for easy installs

""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()
set autowrite
set incsearch
set shiftwidth=4
set softtabstop=4
set ignorecase smartcase
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
set foldmethod=indent
set foldlevel=99
nnoremap <space> za
set omnifunc=syntaxcomplete#Complete

filetype on
filetype plugin on
filetype plugin indent on

autocmd FileType c setlocal textwidth=80
autocmd FileType cpp setlocal textwidth=80
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p

if v:version > 700
    set cursorline
    hi CursorLine ctermbg = Red guibg = #F5FBF6
endif
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=Black guibg=#589A5D

highlight ColorColumn ctermbg=magenta
call matchadd('colorcolumn','\%80v',100)
" Lets make cursor have same functionality like in windows environment
behave mswin

""""""""""""""""""""""""""""""""""""""
"Let me try some random font changes

""""""""""""""""""""""""""""""""""""""
syntax enable
"colorscheme desert
colorscheme jellybeans
set background=dark
set guifont=Monospace\ 10

"""""""""""""""""""""""""""""""""""""
" Let me add few more font options

"""""""""""""""""""""""""""""""""""""
if has("gui_running")
	set guioptions -=T
	set guioptions +=e
	set t_Co=256
	set guitablabel=%M\ %t
endif

"""""""""""""""""""""""""""""""""""
" Adding guicolorscheme plugin set

"""""""""""""""""""""""""""""""""""
 set t_Co=256
 if (&t_Co == 256 || &t_Co == 88) && !has('gui_running') &&
	\ filereadable(expand("$HOME/.vim/plugin/guicolorscheme.vim"))
	   runtime! plugin/guicolorscheme.vim
endif

"""""""""""""""""""""""""""""""""""""
" Cursor color changes

"""""""""""""""""""""""""""""""""""""
if &term =~ "xterm\\|rxvt"
    " use an orange cursor in insert mode
    let &t_SI = "\<Esc>]12;green\x7"
    " use a red cursor otherwise
    let &t_EI = "\<Esc>]12;red\x7"
    silent !echo -ne "\033]12;red\007"
    " reset cursor when vim exits
    autocmd VimLeave * silent !echo -ne "\033]112\007"
    " use \003]12;gray\007 for gnome-terminal and rxvt up to
    version 9.21
endif
