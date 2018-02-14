set nocompatible              " be iMproved, required

" clear all weird mappings before loading
mapclear

filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'scrooloose/syntastic'
Plugin 'Shougo/neocomplcache.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'vim-scripts/bufkill.vim'
"Plugin 'vim-scripts/dbext.vim'
"Plugin 'derekwyatt/vim-scala'
"Plugin 'git://git.code.sf.net/p/vim-latex/vim-latex'
"Plugin 'othree/html5.vim'
Plugin 'scrooloose/nerdtree'
" RST plugin
"Plugin 'Rykka/riv.vim'
" TO work with React this two are useful
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'

" To enable code snippets
"Plugin 'MarcWeber/vim-addon-mw-utils'
"Plugin 'tomtom/tlib_vim'
"Plugin 'garbas/vim-snipmate'

" Optional:
"Plugin 'honza/vim-snippets'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" test stuff
"setl foldmethod=syntax

set encoding=utf8

set termguicolors " True colors

" Color first, so I can customize later
if &diff
	colorscheme monokai "too cool :)
else
	colorscheme monokai "koehler
endif

"Autoreload self
autocmd! bufwritepost ~/.vimrc source %

" Automagically indent templates
au BufNewFile,BufRead *.less set filetype=css
au BufNewFile,BufRead *.html.tmpl set filetype=html
au BufNewFile,BufRead *.psql.tmpl set filetype=sql

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" My editor my rules
set textwidth=120
set wrapmargin=2
"set wrap "Wrap lines
"set linebreak
"
" Keep all backups in one place, needs to be aligned with the system (VIM does
" not create directories)
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

" keep 100 lines of command line history
set history=100

" show the cursor position all the time
set ruler

" display incomplete commands
set showcmd

" Switch syntax highlighting on
syntax on

set guioptions-=T
set guioptions+=e
set t_Co=65536
set guitablabel=%M\ %t

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Cursor highlighting
highlight Cursor guifg=blue guibg=white
" highlight iCursor guifg=white guibg=steelblue
" Disabled for Neovim set guicursor=n-v-c:block-Cursor
" set guicursor+=i:ver100-iCursor
" set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

" 1 tab == X spaces
set shiftwidth=2
set tabstop=2
set sts=2
set expandtab

" Python settings
autocmd Filetype python setlocal ts=4 sts=4 sw=4

" More space in JSON files
autocmd BufEnter *.json :set ts=4 sts=4 sts=4

set ai "Auto indent
set si "Smart indent

"Some buffer facilities
map <C-n> :bnext<CR>
map <C-b> :bp<CR>

" Testing: change workspace to current file's location
"set autochdir
"autocmd BufEnter * silent! lcd %:p:h

" Super needed in order for multiple buffers to work properly
set laststatus=2

" use menu for command line completion
"set wildmenu

set statusline= "clear, for when vimrc is reloaded
set statusline+=%.80F%m%r%h%w
set statusline+=\ [ENC=%{&fenc}]
set statusline+=\ [TYPE=%Y]
set statusline+=%= " right align
set statusline+=\ [POS=%.4l/%.4L\ (%p%%)]

" So it doesn't ask to save evertytime you move out of buffers
set hidden

" Delete trailing white space on save, useful ALWAYS
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite * :call DeleteTrailingWS()

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>
map <leader>np :setlocal nopaste!<cr>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Open new splits to right and bottom, feels more natural
set splitbelow
set splitright

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Toggle Syntastic status
noremap <leader>st :SyntasticToggle<cr>

" Force Check
noremap <leader>sc :SyntasticCheck<cr>

let g:syntastic_javascript_checkers = ['eslint'] " npm
let g:syntastic_go_checkers = ['gometalinter']
let g:syntastic_py_checkers = ['pylint'] " PIP
let g:syntastic_rst_checkers = ['sphinx'] " PIP
let g:syntastic_scala_checkers = ['scalac']
let g:syntastic_sh_checkers = ['shellcheck'] " Package manager
let g:syntastic_sql_checkers = ['sqlint'] " Ruby gem
let g:syntastic_yaml_checkers = ['yamllint'] " PIP
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_auto_jump = 0
let g:syntastic_error_symbol = "🔥"
let g:syntastic_warning_symbol = "🌧 "
let g:syntastic_style_error_symbol = "🔥"
let g:syntastic_style_warning_symbol = "🌧 "

" Completion stuff
let g:neocomplcache_enable_at_startup=1
set omnifunc=syntaxcomplete#Complete
set completeopt=longest,menuone
highlight Pmenu ctermfg=black ctermbg=lightblue
highlight PmenuSel ctermfg=white ctermbg=red

" Spell checking!
let b:myLang=0
let g:myLangList=["nospell","en_gb"]
function! ToggleSpell()
  if !exists( "b:myLang" )
    if &spell
      let b:myLang=index(g:myLangList, &spelllang)
    else
      let b:myLang=0
    endif
  endif
  let b:myLang=b:myLang+1
  if b:myLang>=len(g:myLangList)
    let b:myLang=0
  endif
  if b:myLang==0
    setlocal nospell
  else
    execute "setlocal spell spelllang=".get(g:myLangList, b:myLang)
  endif
  echo "spell checking language:" g:myLangList[b:myLang]
endfunction

nmap <silent> <F7> :call ToggleSpell()<CR>
" ]s -> next spelling error
nmap z+ ]s
" [s -> previous spelling error
nmap z- [s
" z= -> bring up list of suggestions
" zg -> Add current spelling error to dictionary

" Set type for custom extensions:
" hbs: Handlebars template
autocmd BufEnter *.hbs :set ft=html

" Command to yank into clipboard (needs vim-gtk)
if has('clipboard')==1
  " for Linux
  "set clipboard=unnamedplus
  " for OSX
  set clipboard=unnamed
endif

" Nerdtree starts OFF by default
"autocmd vimenter * NERDTree

" Filter out some files
let NERDTreeIgnore = ['\.pyc$', '\.o$[[file]]']

" CLose vim if the only window left open is nerdtree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"nmap <silent> <F2> :NERDTreeToggle<CR>
map <leader>nt :NERDTreeToggle<cr>
map <leader>ff :NERDTreeFind<cr>

" Scala-vim
let g:scala_scaladoc_indent = 1

" JSX-enabled for 'js' files
let g:jsx_ext_required = 0

" Search highlighting
hi Search ctermbg=DarkYellow ctermfg=Yellow
