call plug#begin('~/.config/nvim/plugged')

Plug '/usr/bin/fzf'
Plug 'airblade/vim-gitgutter'
Plug 'aliou/bats.vim'
Plug 'bazelbuild/vim-bazel'
Plug 'bling/vim-airline'
Plug 'bronson/vim-trailing-whitespace'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'folke/lsp-colors.nvim'
Plug 'folke/trouble.nvim'
Plug 'gabrielelana/vim-markdown'
Plug 'google/vim-maktaba'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'mhartington/formatter.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'romainl/Apprentice'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'towolf/vim-helm'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vimwiki/vimwiki'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'zivyangll/git-blame.vim'

call plug#end()


lua << EOF
local nvim_lsp = require('lspconfig')

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "bashls", "ansiblels", "dockerls", "eslint", "html", "helm_ls", "jsonls", "jdtls", "tsserver", "marksman", "puppet", "pylsp", "yamlls"},
  automatic_installation = True,
}

require('trouble').setup{}
nvim_lsp.bashls.setup{
  filetypes = { "sh", "bash" }
}

nvim_lsp.jdtls.setup{}
nvim_lsp.eslint.setup{}

EOF

let g:markdown_enable_spell_checking = 1
let g:markdown_enable_folding = 0

let NERDTreeIgnore = ['\.pyc$']
let NERDTreeShowHidden=1
let g:NERDTrimTrailingWhitespace = 1

let g:rustfmt_autosave = 1

let mapleader=","

" Search for file in current dir
nmap <leader>ff :Files<CR>
nmap <leader>fb :Buffers<CR>
nmap <leader>fs :Ag


" Remove search highlights
map <Leader>/ :let @/ = ""<CR>
noremap <leader>W :w !sudo tee % > /dev/null<CR> " save with sudo
nnoremap <Leader>d :r! date +'\%Y.\%m.\%d'<CR> " insert timestamp

" ,s to search and replace word under cursor
nnoremap <Leader>sr :%s/\<<C-r><C-w>\>/
nnoremap <leader>sc :setlocal spell!<cr> " toggle spellchehck

let g:vimwiki_list = [{'path': '~/src/brujoand/wiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki#nested_syntaxes = {'ruby': 'ruby', 'python': 'python', 'c++': 'cpp', 'sh': 'sh', 'racket': 'racket'}
let g:vimwiki_hl_headers = 1
au BufRead,BufNewFile *.md setlocal textwidth=80
au BufRead,BufNewFile *.wiki setlocal textwidth=80
au BufRead,BufNewFile *.md setlocal spell spelllang=en_us
au BufRead,BufNewFile *.wiki setlocal spell spelllang=en_us

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
let g:airline#extensions#tabline#enabled = 1 " Show my buffers
let g:airline#extensions#tabline#fnamemod = ':t' " But just the filename
nmap <leader>l :bnext<CR>
nmap <leader>h :bprevious<CR>

syntax enable
set background=dark
set t_Co=256
set termguicolors
colorscheme apprentice
set guifont=Source\ Code\ Pro\ for\ Powerline "make sure to escape the spaces in the name properly

set statusline+=%#warningmsg#
set statusline+=%*

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
set cursorcolumn            " highlight current line

set backupdir=~/.config/nvim/.backup// " don't make a mess
set directory=~/.config/nvim/.swp//    " not even for swap files

autocmd! BufWritePost *
autocmd! BufReadPost *
augroup AutoCommands
    autocmd BufWritePost init.vim source ~/.config/nvim/init.vim
augroup END

" Have vim put the cursor where it was the last time we viewed this file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set guifont=Meslo\ LG\ S\ DZ\ for\ Powerline "make sure to escape the spaces in the name properly


nnoremap <silent> <leader>t :NERDTreeToggle<CR>
nnoremap <silent> <leader>T :NERDTreeFind<CR>

let g:python_recommended_style = 0
