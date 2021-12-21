let mapleader =","

set bg=light
set go=a
set mouse=a
set nohlsearch
" set clipboard+=unnamedplus

" Use this one if you want to use Middle click to paste copied text from vim
" set clipboard=unnamed

" Use this one if you want to use primary clipboard! 
set clipboard=unnamedplus

" Though for this we need xsel (https://github.com/neovim/neovim/issues/7945)

colorscheme delek

" Some basics:
	"nnoremap c "_c
	set nocompatible
	filetype plugin on
	syntax on
	set encoding=utf-8
	set number relativenumber
	"set softtabstop=4
	"set shiftwidth=4
" Enable autocompletion:
	"set wildmode=longest,list,full
" Disables automatic commenting on newline:
	"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
	"set splitbelow splitright

" Shortcutting split navigation, saving a keypress:
	"map <C-h> <C-w>h
	"map <C-j> <C-w>j
	"map <C-k> <C-w>k
	"map <C-l> <C-w>l

" Replace ex mode with gq
	"map Q gq

" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
    highlight! link DiffText MatchParen
endif
