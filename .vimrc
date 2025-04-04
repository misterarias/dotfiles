set nocompatible              " be iMproved, required

" clear all weird mappings before loading
mapclear

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')

" Copilot wins dude
"Plug 'ycm-core/YouCompleteMe'

" Install your UIs
"Plug 'Shougo/ddc-ui-native'
"
"" Install your sources
"Plug 'Shougo/ddc-source-around'
"
"" Install your filters
"Plug 'Shougo/ddc-matcher_head'
"Plug 'Shougo/ddc-sorter_rank'

Plug 'junegunn/vim-plug'

" Use 'dir' option to install plugin in a non-default directory
Plug 'junegunn/fzf', { 'dir': '~/.fzf' }

"Plug 'Shougo/ddc.vim'
"Plug 'vim-denops/denops.vim'
Plug 'https://github.com/ctrlpvim/ctrlp.vim'
Plug 'vim-scripts/bufkill.vim'
"Plug 'vim-scripts/dbext.vim'
"Plug 'derekwyatt/vim-scala'
"Plug 'git://git.code.sf.net/p/vim-latex/vim-latex'
"Plug 'othree/html5.vim'
"Plug 'scrooloose/nerdtree' | Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'preservim/nerdtree', { 'on':  'NERDTreeFind' }
"Plug 'dense-analysis/ale', { 'on': 'ALEEnable' }
Plug 'scrooloose/syntastic'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" TO work with React this two are useful
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'javascript' }
"Plug 'sheerun/vim-polyglot'
Plug 'pearofducks/ansible-vim', { 'for': 'ansible' }
" Write environment
"Plug 'junegunn/goyo.vim'
" Markdown pluginS - https://github.com/plasticboy/vim-markdown
"Plug 'godlygeek/tabular'
"Plug 'plasticboy/vim-markdown'
" Better status bar
" GIT integration
" Plug 'tpope/vim-fugitive'
"Plug 'davidhalter/jedi-vim'   " Remember to globally install Jedi
"Plug 'martinda/Jenkinsfile-vim-syntax'
Plug 'rust-lang/rust.vim', { 'for': 'rust'}
Plug 'speshak/vim-cfn', { 'for': 'yaml' }
Plug 'hashivim/vim-terraform', { 'for': 'hcl' }

" Has to enabled on connected accountirloine
Plug 'github/copilot.vim'

call plug#end()

" test stuff
"au BufNewFile,BufRead *.json setl foldmethod=syntax

set encoding=utf8

set termguicolors " True colors

" Color first, so I can customize later
if $ITERM_PROFILE == "Hotkey"
  colorscheme delek
else
  colorscheme koehler " monokai
endif

" Start scrolling three lines before the horizontal window border
set scrolloff=3

"Autoreload self
autocmd! bufwritepost ~/.vimrc source %

" Automagically indent templates
au BufNewFile,BufRead *.less set filetype=css
au BufNewFile,BufRead *.html.tmpl set filetype=html
au BufNewFile,BufRead *.yaml.template set filetype=yaml
au BufNewFile,BufRead *.psql.tmpl set filetype=sql

" Custom formats
au BufNewFile,BufRead *Jenkinsfile set filetype=groovy
au BufNewFile,BufRead *.cf.yml set filetype=cloudformation

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
set textwidth=1000

set wrapmargin=2
"set wrap "Wrap lines
"set linebreak
"
" Keep all backups in one place, needs to be aligned with the system (VIM does
" not create directories)
set backup
set backupdir=~/.vim/backup//
set directory=~/.vim/tmp//

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
" highlight Cursor guifg=blue guibg=white
hi Search ctermbg=DarkYellow ctermfg=Yellow
" highlight iCursor guifg=white guibg=steelblue

" 1 tab == X spaces
set shiftwidth=4
set tabstop=4
set sts=4
set expandtab
set list
set listchars=tab:␉·,trail:␠

" More space in certain files (TODO maybe all...)
"autocmd Filetype * setlocal ts=4 sts=4 sw=4
"autocmd Filetype python setlocal ts=4 sts=4 sw=4
"autocmd Filetype groovy setlocal ts=4 sts=4 sw=4
"autocmd FileType json :set ts=4 sts=4 sts=4
"autocmd FileType json :set ts=4 sts=4 sts=4

" Map weird types
au BufNewFile,BufRead *.gs set filetype=javascript

set ai "Auto indent
set si "Smart indent

"Some buffer facilities
map <C-n> :bnext<CR>
map <C-b> :bp<CR>
map <C-c> :BW<CR>


" Super needed in order for multiple buffers to work properly
set laststatus=2

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

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
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

" Toggle Syntastic status
noremap <leader>st :SyntasticToggle<cr>

" Force Check
noremap <leader>sc :SyntasticCheck<cr>

let g:syntastic_javascript_checkers = ['eslint'] " npm
let g:syntastic_go_checkers = ['go']
let g:syntastic_rst_checkers = ['sphinx'] " PIP
let g:syntastic_scala_checkers = ['scalac']
let g:syntastic_sh_checkers = ['shellcheck'] " Package manager
let g:syntastic_sql_checkers = ['sqlint'] " Ruby gem
let g:syntastic_yaml_checkers = ['yamllint'] " PIP
let g:syntastic_python_checkers=['flake8']  "   TODO: make mypy fast, 'mypy'] "PIP - TODO use mypy
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_auto_jump = 0
let g:syntastic_error_symbol = "🔥"
let g:syntastic_warning_symbol = "⛈️ "
let g:syntastic_style_error_symbol = "🔥"
let g:syntastic_style_warning_symbol = "🌧 "
let g:syntastic_cloudformation_checkers = ['cfn_lint']


" Completion stuff
let g:neocomplcache_enable_at_startup=1
set omnifunc=syntaxcomplete#Complete
set completeopt=longest,menuone
highlight Pmenu ctermfg=black ctermbg=lightblue
highlight PmenuSel ctermfg=white ctermbg=red


" Command to yank into clipboard (needs vim-gtk)
if has('clipboard')==1
  "set clipboard=unnamedplus
  set clipboard=unnamed
endif

" Nerdtree starts OFF by default
"autocmd vimenter * NERDTree

" Filter out some files
let NERDTreeIgnore = ['\.pyc$', '\.o$[[file]]']

" Show hidden images by default
let NERDTreeShowHidden=1

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

" YAML Ansible
let g:ansible_unindent_after_newline=1

" CtrlP custom settings
"let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_mruf_case_sensitive = 1
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_show_hidden = 1
let g:ctrlp_user_command = 'fd --hidden --full-path %s'        " MacOSX/Linux
"set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
let g:ctrlp_custom_ignore = '\v[\/](Library|Libraries|Applications|node_modules|build|target|out|\.(git|hg|svn))$'

" Open file in chrome
nmap <silent> <leader>gc :!/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome %<CR>

" Markdown + monokai : horrible
autocmd Filetype markdown colorscheme default

" Goyo defaults
" let g:goyo_width = 150
" g:goyo_height` (default: 85%)

" Mapping for vimgrep
map <leader>vg :execute " grep -srnw --binary-files=without-match --exclude-dir=.git --exclude-dir=build --exclude-dir=no --exclude-dir=e_modules . -e " . expand("<cword>") . " " <bar> cwindow<CR>

" Tab movement
map <leader>tn :tabNext<CR>
map <leader>tp :tabprevious<CR>
map <leader>tc :tabclose<CR>

" vim-airline configuration
let g:airline_theme = 'dark' "'powerlineish'
let g:airline_powerline_fonts = 1
let t_Co=256
"" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
"" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

"" Enable copilot in all buffers
let b:copilot_enabled=v:true
"let g:copilot_proxy = '127.0.0.1:8999'  "'proxyvip.igrupobbva:8080'
"let g:copilot_proxy_strict_ssl = v:false


" Enable powerline (installed from pip3 install powerline-status --break-system-packages.)
"" let g:Powerline_symbols = 'unicode'
"" python3 from powerline.vim import setup as powerline_setup
"" python3 powerline_setup()
"" python3 del powerline_setup
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)

" Chat gpt suggestions
let g:loaded_matchparen = 1
let g:loaded_2html_plugin = 1
let g:loaded_remote_plugins = 1
let g:loaded_shada_plugin = 1
let g:loaded_tutor_mode_plugin = 1

set shell=/bin/sh
