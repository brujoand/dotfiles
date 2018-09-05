call plug#begin('~/.config/nvim/plugged')


Plug 'romainl/Apprentice'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'bling/vim-airline'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'leafgarland/typescript-vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'vimwiki/vimwiki'
Plug 'gabrielelana/vim-markdown'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'fatih/vim-go'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'benekastah/neomake'
Plug 'ensime/ensime-vim', { 'do': ':UpdateRemotePlugins' }
Plug 'derekwyatt/vim-scala'
Plug 'dln/avro-vim'
Plug 'spf13/vim-autoclose'

call plug#end()

let g:vimwiki_list = [{'path': '~/Dropbox/wiki'}]
let g:markdown_enable_spell_checking = 0

nnoremap <silent> <leader><space> :FZF<CR>
let NERDTreeIgnore = ['\.pyc$']

let g:deoplete#enable_at_startup = 1

let mapleader=","

map <Leader>/ :let @/ = ""<CR>
noremap <leader>W :w !sudo tee % > /dev/null<CR> " save with sudo
" ,s to search and replace word under cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
"nnoremap <Leader>d :r! date +'\%Y.\%m.\%d'<CR> " insert timestamp
nnoremap <leader>sc :setlocal spell!<cr> " toggle spellchehck
nnoremap <Leader>d :r! date +'\%Y.\%m.\%d'<CR> " insert timestamp


au FileType scala nnoremap <leader>d :EnDeclaration<CR>
au FileType scala nnoremap <leader>b :EnDocBrowse<CR>
au BufRead,BufNewFile *.avdl setlocal filetype=avro-idl

inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"

" Let's make term mode better
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
tnoremap <Esc> <C-\><C-n> " Let esc exit term mode

" Save often, cry less
autocmd InsertLeave * write

" {{{ Vimwiki plugin settings and specific functions: "
let g:vimwiki_list = [{
          \ 'path': '~/Dropbox/vimwiki',
          \ 'template_path': '~/Dropbox/vimwiki/templates/',
          \ 'nested_syntaxes': {
          \   'ruby': 'ruby',
          \   'python': 'python',
          \   'javascript': 'javascript',
          \   'bash': 'sh'
          \  },
          \ 'template_default': 'default',
          \ 'path_html': '~/Dropbox/vimwiki/site_html/',
          \ 'template_ext': '.tpl'
          \ }]

autocmd FileType vimwiki set spell spelllang=en_gb
" }}}


" Fix broken clipboard
set clipboard=unnamed

set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

let g:airline_powerline_fonts = 1 " use powerline fonts
set laststatus=2            " make airline show up with at once
let g:airline#extensions#tabline#enabled = 1 " Show my buffers
let g:airline#extensions#tabline#fnamemod = ':t' " But just the filename
nmap <leader>l :bnext<CR>
nmap <leader>h :bprevious<CR>

syntax enable
set background=dark
colorscheme apprentice
set guifont=Source\ Code\ Pro\ for\ Powerline "make sure to escape the spaces in the name properly

set statusline+=%#warningmsg#
set statusline+=%*
let g:neomake_sh_shellcheck_maker = {
    \ 'args': ['-x', '-fgcc'],
      \ 'errorformat':
          \ '%f:%l:%c: %trror: %m,' .
          \ '%f:%l:%c: %tarning: %m,' .
          \ '%I%f:%l:%c: Note: %m',
      \ }

let g:neomake_javascript_enabled_makers = ['jshint']

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
autocmd! BufReadPost * Neomake
augroup AutoCommands
    autocmd BufWritePost init.vim source ~/.config/nvim/init.vim
augroup END

nnoremap <silent> <leader>t :NERDTreeToggle<CR>
nnoremap <silent> <leader>f :NERDTreeFind<CR>

