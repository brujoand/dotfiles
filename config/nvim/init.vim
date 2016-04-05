call plug#begin('~/.config/nvim/plugged')

Plug 'romainl/Apprentice'
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'scrooloose/nerdtree'
Plug 'bling/vim-airline'
Plug 'benekastah/neomake'
Plug 'Yggdroot/indentLine'
Plug 'bronson/vim-trailing-whitespace'

call plug#end()

let mapleader=","
map <Leader>/ :let @/ = ""<CR>
noremap <leader>W :w !sudo tee % > /dev/null<CR> " save with sudo
" ,s to search and replace word under cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

set rtp+=/usr/local/Cellar/fzf/0.11.3/
nnoremap <silent> <leader><space> :FZF<CR>
nnoremap <silent> <leader>t :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$']
let g:fzf_action = {
  \ 'ctrl-m': 'e',
  \ 'ctrl-t': 'tabedit',
  \ 'alt-j':  'botright split',
  \ 'alt-k':  'topleft split',
  \ 'alt-h':  'vertical topleft split',
  \ 'alt-l':  'vertical botright split' }

let g:deoplete#enable_at_startup = 1
inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"



" Save often, cry less
autocmd InsertLeave * write

" Fix broken clipboard
set clipboard=unnamed

set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

let g:airline_powerline_fonts = 1 " use powerline fonts
set laststatus=2            " make airline show up with at once

syntax enable
set background=dark
colorscheme apprentice
set guifont=Source\ Code\ Pro\ for\ Powerline "make sure to escape the spaces in the name properly

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux'
  set t_Co=16
endif

set backspace=indent,eol,start " So that backspace will 'work'

set tabstop=2               " 4 space tab
set expandtab               " use spaces for tabs
set softtabstop=2           " 4 space tab
set shiftwidth=2
filetype plugin on          " detect filetype
set number                  " show line numbers
set ruler                   " show cursor position
set showcmd                 " show command in bottom bar
set cursorline              " highlight current line

set backupdir=~/.config/nvim/.backup// " don't make a mess
set directory=~/.config./nvim/.swp//    " not even for swap files

" Have vim put the cursor where it was the last time we viewed this file
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

autocmd! BufWritePost * Neomake
