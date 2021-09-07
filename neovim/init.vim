" ----------------------------------------------------------------------
" Options
" ----------------------------------------------------------------------

set diffopt+=iwhite		        " Ignore whitespace in vimdiff	
set encoding=utf-8              " Set default encoding to UTF-8
set background=dark
syntax enable
set t_Co=256              	    " Use 256 colors

" line numbering
set ruler                 	    " Show the line number and column in the status bar
set number
set relativenumber
set colorcolumn=80        	    " Highlight 80 character limit
set wrap
set textwidth=79


set hidden                  	" Allow buffers to be backgrounded without being saved
set laststatus=2            	" Always show the status bar
"set list                   	" Show invisible characters
"set listchars=tab:›\ ,eol:¬,trail:⋅ " Set the characters for the invisibles
set scrolloff=999           	" Keep the cursor centered in the screen
set showmatch             	    " Highlight matching braces
set showcmd                     " Show me what I'm typing
set showmode              	    " Show the current mode on the open buffer
set splitbelow              	" Splits show up below by default
set splitright              	" Splits go to the right by default
set backspace=indent,eol,start  " Makes backspace key more powerful.
set mouse=a

" search settings
set incsearch                	" Shows the match while typing
set hlsearch                 	" Highlight found searches
set ignorecase               	" Search case insensitive...
set smartcase                	" ... but not when search pattern contains upper case characters

" file settings
set noswapfile                  " Don't use swapfile
set nobackup			        " Don't create annoying backup files
set nowritebackup
set autowrite                   " Automatically save before :next, :make etc.
set autoread                    " Automatically reread changed files without asking me anything
set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats

" Tab settings
set expandtab     		        " Expand tabs to the proper type and size
set tabstop=4     		        " Tabs width in spaces
set softtabstop=4 		        " Soft tab width in spaces
set shiftwidth=4  		        " Amount of spaces when shifting

" ----------------------------------------------------------------------
" Key Mappings
" ----------------------------------------------------------------------

" This comes first, because we have mappings that depend on leader
" With a map leader it's possible to do extra key combinations
" i.e: <leader>w saves the current file
let mapleader = ";"
let g:mapleader = ";"

" Remap a key sequence in insert mode to kick me out to normal
" mode. This makes it so this key sequence can never be typed
" again in insert mode, so it has to be unique.
imap jk <ESC>

" Shortcut to yanking to/from the system clipboard
map <leader>y "+y
map <leader>p "+p

" Buffer management
nnoremap <leader>d :bd<cr>
" Buffer prev/next
nnoremap <C-x> :bnext<CR>
nnoremap <C-z> :bprev<CR>
" Fast saving
nmap <leader>w :w!<cr>
nnoremap <silent> <leader>q :q!<CR>

" Get rid of search highlights
noremap <silent><leader><space> :nohlsearch<cr>


" =================== vim-shfmt ========================
autocmd BufWritePost *.bats !shfmt -w -ln bats <afile>
let g:shfmt_fmt_on_save = 1

" =================== vim-terraform ========================

"Allow vim-terraform to automatically fold (hide until unfolded) sections of terraform code.
let g:terraform_fold_sections=0

" Run terraform fmt on save.
let g:terraform_fmt_on_save=1
