call plug#begin('~/.config/nvim/plugged')

Plug 'romainl/Apprentice'
Plug 'scrooloose/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'bling/vim-airline'
Plug 'bronson/vim-trailing-whitespace'
Plug 'vimwiki/vimwiki'
Plug 'gabrielelana/vim-markdown'
Plug 'airblade/vim-gitgutter'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'neomake/neomake'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'rust-lang/rust.vim'

call plug#end()

let g:vimwiki_list = [{'path': '~/Documents/wiki'}]
let g:markdown_enable_spell_checking = 0

let NERDTreeIgnore = ['\.pyc$']
let g:NERDTrimTrailingWhitespace = 1

let g:coc_node_path = '/usr/local/bin/node'

let g:rustfmt_autosave = 1

let mapleader=","

" Search for file in current dir
nmap <leader>f :Files<CR>
nmap <leader>; :Buffers<CR>

" Remove search highlights
map <Leader>/ :let @/ = ""<CR>
noremap <leader>W :w !sudo tee % > /dev/null<CR> " save with sudo
nnoremap <Leader>d :r! date +'\%Y.\%m.\%d'<CR> " insert timestamp

" ,s to search and replace word under cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
nnoremap <leader>sc :setlocal spell!<cr> " toggle spellchehck

au BufRead,BufNewFile *.md setlocal textwidth=80
au BufRead,BufNewFile *.wiki setlocal textwidth=80
au BufRead,BufNewFile *.md setlocal spell spelllang=en_us
au BufRead,BufNewFile *.wiki setlocal spell spelllang=en_us

inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"

" Save often, cry less
autocmd InsertLeave * write

" {{{ Vimwiki plugin settings and specific functions: "
let g:vimwiki_list = [{
          \ 'path': '~/Documents/vimwiki',
          \ 'template_path': '~/Documents/vimwiki/templates/',
          \ 'nested_syntaxes': {
          \   'ruby': 'ruby',
          \   'python': 'python',
          \   'javascript': 'javascript',
          \   'bash': 'sh'
          \  },
          \ 'template_default': 'default',
          \ 'path_html': '~/Documents/vimwiki/site_html/',
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
set t_Co=256
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
set directory=~/.config/nvim/.swp//    " not even for swap files

autocmd! BufWritePost * Neomake
autocmd! BufReadPost * Neomake
augroup AutoCommands
    autocmd BufWritePost init.vim source ~/.config/nvim/init.vim
augroup END

" Have vim put the cursor where it was the last time we viewed this file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set guifont=Meslo\ LG\ S\ DZ\ for\ Powerline "make sure to escape the spaces in the name properly


nnoremap <silent> <leader>t :NERDTreeToggle<CR>
