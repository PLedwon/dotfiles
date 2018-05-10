	set nocompatible
	filetype plugin on
	syntax on
	"colorscheme wal
	set encoding=utf-8
	set number
	set relativenumber
	
" Runs a script that cleans out tex build files whenever I close out of a .tex file.
	autocmd VimLeave *.tex !texclear
	
	
" Enable autocompletion:
	set wildmode=longest,list,full
	set wildmenu


" C-T for new tab
	nnoremap <C-t> :tabnew<cr>

" Navigating with guides
	inoremap <Space><Tab> <Esc>/<++><Enter>"_c4l
	vnoremap <Space><Tab> <Esc>/<++><Enter>"_c4l
	map <Space><Tab> <Esc>/<++><Enter>"_c4l
	inoremap ;gui <++>

" Compile document using pdflatex:
	autocmd FileType tex inoremap <F5> <Esc>:!pdflatex<space><c-r>%<Enter>a
	autocmd FileType tex nnoremap <F5> :!pdflatex<space><c-r>%<Enter>
autocmd FileType tex inoremap ;bg \begin{frame}<Enter>\frametitle{}<Enter><Enter><++><Enter><Enter>\end{frame}<Enter><Enter><++><Esc>6kf}i
