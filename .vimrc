	set nocompatible
	filetype plugin on
	syntax on
	"colorscheme wal
	set encoding=utf-8
	set number
	set relativenumber

	" Compile document using pdflatex:
	autocmd FileType tex inoremap <F5> <Esc>:!pdflatex<space><c-r>%<Enter>a
	autocmd FileType tex nnoremap <F5> :!pdflatex<space><c-r>%<Enter>
