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

nnoremap <C-e> :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>

nnoremap <C-p> :Telescope find_files<CR>
nnoremap <leader>p :Telescope buffers<CR>

nnoremap <leader>a :BufferPrevious<CR>
nnoremap <leader>e :BufferNext<CR>

nnoremap <C-t> :SymbolsOutline<CR>

nmap <leader>tld <Plug>(toggle-lsp-diag)

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
set cursorline
set nohlsearch

autocmd FileType text lua require 'cmp'.setup.buffer { sources = {} }

highlight ExtraWhitespace guibg=red
match ExtraWhitespace /\s\+$/

highlight NvimTreeSpecialFile guifg='#f0c674'
highlight NvimTreeRootFolder guifg='#b294bb'
