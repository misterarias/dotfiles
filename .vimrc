set nocompatible              " be iMproved, required
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
Plugin 'vim-scripts/dbext.vim'
"Plugin 'derekwyatt/vim-scala'
"Plugin 'git://git.code.sf.net/p/vim-latex/vim-latex'
Plugin 'othree/html5.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

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
set textwidth=240
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

" Switch syntax highlighting on, when the terminal has colors
syntax on
if has("gui_running")
    set guioptions-=T
    set guioptions+=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Use Unix as the standard file type
set ffs=unix,dos,mac

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2
set sts=2
set expandtab
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype python setlocal ts=4 sts=4 sw=4

set ai "Auto indent
set si "Smart indent

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

if &diff
	colorscheme monokai "too cool :)
else
	colorscheme monokai
endif

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()
autocmd BufWrite *.rb :call DeleteTrailingWS()

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

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

let g:syntastic_yaml_checkers = ['yaml-lint']
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_auto_jump = 0
let g:syntastic_error_symbol = "✗"
let g:syntastic_warning_symbol = "⚠"

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
  set clipboard=unnamedplus
endif
