lua require('plugins')
lua require('init')

let mapleader = ","

" Just Dvorak things
noremap t k
noremap k t
noremap n j
noremap j n
noremap s l
noremap l s
inoremap hh <Esc>
nnoremap ; :
map <C-h> <C-w>h
map <C-n> <C-w>j
map <C-t> <C-w>k
map <C-s> <C-w>l

nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>

nnoremap <C-p> :Files<CR>
nnoremap <leader>p :Buffers<CR>

nnoremap <leader>a :BufferPrevious<CR>
nnoremap <leader>o :BufferNext<CR>

"let g:gruvbox_contrast_dark = 'hard'
"colorscheme gruvbox
"colorscheme base16-tomorrow-night

set number
set termguicolors
set tabstop=4
set shiftwidth=4
set expandtab
set wildmode=longest,list,full
set wildmenu
set completeopt=menu,menuone,noselect
set mouse=a
set clipboard+=unnamedplus
set hidden

autocmd FileType text lua require 'cmp'.setup.buffer { sources = {} }

highlight ExtraWhitespace guibg=red
match ExtraWhitespace /\s\+$/

highlight NvimTreeSpecialFile guifg='#f0c674'
highlight NvimTreeRootFolder guifg='#b294bb'

let $FZF_DEFAULT_COMMAND='fd --type f'
