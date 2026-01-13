" Maintainer: Sai Kumar Dwivedi <saidwivedi@gmail.com>
" Last Update: 14.12.21

"-----------------General Settings--------------------
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
set noswapfile
set backupdir-=.
set backupdir^=~/tmp,/tmp
set backspace=indent,eol,start
set number " Turn on line numbers
set relativenumber
set ic " Ignore Case
set shiftwidth=4
set tabstop=4
set autoindent  " always set autoindenting on
set smartindent
set guifont=Monospace\ 9
set history=50  " keep 50 lines of command line history
set ruler       " show the cursor position all the time
set showcmd     " display incomplete commands
set incsearch   " do incremental searching
" Use default color scheme
colorscheme default

" Enhanced syntax highlighting settings
set termguicolors           " Enable 24-bit RGB colors
set t_Co=256               " Enable 256 colors

" Better syntax highlighting without overriding default colors
syntax enable              " Enable syntax processing
set synmaxcol=200          " Limit syntax highlighting for performance

" Highlight current line with subtle styling
set cursorline

"----------------Python-Specific Syntax Highlighting----------------
" Enhanced Python syntax highlighting
let python_highlight_all = 1
let python_highlight_space_errors = 0
let python_highlight_indent_errors = 0

" Python-specific autocmd group
augroup PythonSyntax
    autocmd!
    autocmd FileType python setlocal tabstop=4
    autocmd FileType python setlocal softtabstop=4
    autocmd FileType python setlocal shiftwidth=4
    autocmd FileType python setlocal textwidth=88
    autocmd FileType python setlocal expandtab
    autocmd FileType python setlocal autoindent
    autocmd FileType python setlocal fileformat=unix

    " Enhanced Python syntax highlighting
    autocmd FileType python syntax keyword pythonBuiltinFunc abs all any bin bool bytearray callable chr classmethod compile complex delattr dict dir divmod enumerate eval filter float format frozenset getattr globals hasattr hash help hex id input int isinstance issubclass iter len list locals map max memoryview min next object oct open ord pow print property range repr reversed round set setattr slice sorted staticmethod str sum super tuple type vars zip
    autocmd FileType python syntax keyword pythonBuiltinObj True False None NotImplemented Ellipsis __debug__
    autocmd FileType python syntax keyword pythonException ArithmeticError AssertionError AttributeError BaseException BlockingIOError BrokenPipeError BufferError BytesWarning ChildProcessError ConnectionAbortedError ConnectionError ConnectionRefusedError ConnectionResetError DeprecationWarning EOFError Ellipsis EnvironmentError Exception FileExistsError FileNotFoundError FloatingPointError FutureWarning GeneratorExit IOError ImportError ImportWarning IndentationError IndexError InterruptedError IsADirectoryError KeyError KeyboardInterrupt LookupError MemoryError ModuleNotFoundError NameError NotADirectoryError NotImplemented NotImplementedError OSError OverflowError PendingDeprecationWarning PermissionError ProcessLookupError RecursionError ReferenceError ResourceWarning RuntimeError RuntimeWarning StopAsyncIteration StopIteration SyntaxError SyntaxWarning SystemError SystemExit TabError TimeoutError TypeError UnboundLocalError UnicodeDecodeError UnicodeEncodeError UnicodeError UnicodeTranslateError UnicodeWarning UserWarning ValueError Warning WindowsError ZeroDivisionError

    " Python decorators
    autocmd FileType python syntax match pythonDecorator "@\w\+\(\.\w\+\)*" display

    " Python self keyword
    autocmd FileType python syntax keyword pythonSelf self cls

    " Python string formatting
    autocmd FileType python syntax match pythonStrFormat "{[^}]*}" contained containedin=pythonString,pythonRawString
    autocmd FileType python syntax match pythonStrFormat "%\(([^)]*)\)\?[-#0 +]*\*\?\d*\.\?\d*[hlL]\?[diouxXeEfFgGcrs%]" contained containedin=pythonString,pythonRawString

    " NumPy library highlighting
    autocmd FileType python syntax keyword pythonNumPy np numpy array zeros ones empty full eye identity linspace arange meshgrid reshape transpose dot matmul sum mean std var min max argmin argmax sort argsort unique concatenate stack vstack hstack split where select clip abs sqrt exp log sin cos tan arcsin arccos arctan pi e inf nan random seed randint randn uniform normal ones_like zeros_like empty_like full_like
    autocmd FileType python hi link pythonNumPy pythonLibraryFunc

    " OpenCV (cv2) library highlighting
    autocmd FileType python syntax keyword pythonOpenCV cv2 imread imwrite imshow waitKey destroyAllWindows resize cvtColor COLOR_BGR2RGB COLOR_RGB2BGR COLOR_BGR2GRAY COLOR_GRAY2BGR rectangle circle line putText FONT_HERSHEY_SIMPLEX threshold THRESH_BINARY THRESH_BINARY_INV findContours drawContours contourArea boundingRect approxPolyDP arcLength moments HoughLines HoughCircles Canny GaussianBlur bilateralFilter morphologyEx MORPH_OPEN MORPH_CLOSE MORPH_GRADIENT dilate erode getStructuringElement MORPH_RECT MORPH_ELLIPSE
    autocmd FileType python hi link pythonOpenCV pythonLibraryFunc

    " PyTorch library highlighting
    autocmd FileType python syntax keyword pythonTorch torch tensor zeros ones empty randn rand randint arange linspace eye cat stack unsqueeze squeeze view reshape permute transpose matmul mm bmm sum mean std var min max argmin argmax sort topk clamp abs sqrt exp log sin cos tanh sigmoid softmax relu dropout batch_norm layer_norm conv1d conv2d conv3d max_pool1d max_pool2d avg_pool1d avg_pool2d linear embedding rnn lstm gru transformer save load state_dict parameters named_parameters zero_grad backward step cuda cpu device dtype float32 float64 int32 int64 bool ones_like zeros_like empty_like full_like
    autocmd FileType python hi link pythonTorch pythonLibraryFunc

    autocmd FileType python syntax keyword pythonTorchNN nn Module Sequential Linear Conv1d Conv2d Conv3d MaxPool1d MaxPool2d AvgPool1d AvgPool2d BatchNorm1d BatchNorm2d LayerNorm Dropout ReLU Sigmoid Tanh Softmax LogSoftmax CrossEntropyLoss MSELoss L1Loss BCELoss NLLLoss KLDivLoss
    autocmd FileType python hi link pythonTorchNN pythonLibraryType

    autocmd FileType python syntax keyword pythonTorchOptim optim SGD Adam AdamW RMSprop Adagrad lr_scheduler StepLR ExponentialLR CosineAnnealingLR ReduceLROnPlateau
    autocmd FileType python hi link pythonTorchOptim pythonLibraryType

    autocmd FileType python syntax keyword pythonTorchUtils utils data DataLoader Dataset TensorDataset random_split SubsetRandomSampler BatchSampler
    autocmd FileType python hi link pythonTorchUtils pythonLibraryType
augroup END

" Better invisible characters
set list
set listchars=tab:→\ ,trail:·,extends:…,precedes:…

"Helps search file in the subsequent directory by using <find *.py> and <tab>
set path+=**
set wildmenu

" Keys for folding
" zi/zr/zm -> Toggle/Increase/Decrease Folding Level
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2

set fillchars+=fold:·

"We can use different key mappings for easy navigation between splits to save a keystroke.
"So instead of ctrl-w then j, it’s just ctrl-j:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>

"Navigate faster
noremap <S-j> 4j
noremap <S-k> 4k

"More natural spliting
set splitbelow
set splitright

"removing trailing spaces
autocmd BufWritePre *.* %s/\s\+$//e

" Go the previous/next buffer file
nmap <S-Left> :bprev<CR>
nmap <S-Right> :bnext<CR>

" Ctags Shortcut
map <C-\> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" Remove / from separating word
"set iskeyword+=^/
"set iskeyword+=^-

"-------------------Plugins Settings--------------------
""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"---------------AnyJump----------------
let mapleader = "\<Space>"
function! Preserve(command)
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    "let @/=_s
    call cursor(l, c)
endfunction
"" Normal mode: Jump to definition under cursor
let g:any_jump_disable_default_keybindings = 1
let g:any_jump_list_numbers = 1
nnoremap <leader>j :call Preserve("AnyJump")<CR>
let g:any_jump_ignored_files = ['*.tmp', '*.temp', '*data*', '*logs*']


"---------------NERDTree----------------
"Toggle nerdtree with ctrl + n
let g:NERDTreeWinPos="left"
map <C-n> :NERDTreeToggle<CR>

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif



"----------------ALE-----------------------
"Set preferred linters
let g:ale_linters = {'python': ['flake8', '#pylint']}
"Disable ALE by default
let g:ale_enabled = 0
"Enable ALE
map <C-B> :ALEToggle<CR>
let g:airline#extensions#ale#enabled = 1
"Jump to next Error
nmap <C-e> <Plug>(ale_next_wrap)



"-------------VIM FZF------------------
set rtp+=~/.fzf
let g:fzf_layout = { 'down': '40%' }
nnoremap <leader>o :Files<Cr>
let g:fzf_action = {
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

"-------------VIM Sneak-----------------
" Go the next occurence by pressing ; or previous by ,
let g:sneak#label = 1
map s <Plug>Sneak_s
map S <Plug>Sneak_S
map f <Plug>Sneak_f
map F <Plug>Sneak_F
autocmd ColorScheme * hi SneakLabel guifg=red guibg=yellow ctermfg=red ctermbg=yellow
autocmd ColorScheme * hi Sneak guifg=black guibg=red ctermfg=red ctermbg=yellow

function! GetCommentChar()
    if &filetype == 'javascript' || &filetype == 'typescript' || &filetype == 'cpp' || &filetype == 'java' || &filetype == 'c'
        return '//'
    elseif &filetype == 'vim'
        return '"'
    elseif &filetype == 'html' || &filetype == 'xml'
        return '<!-- '
    elseif &filetype == 'css' || &filetype == 'scss'
        return '/* '
    elseif &filetype == 'sql' || &filetype == 'lua'
        return '--'
    else
        return '#'
    endif
endfunction

function! IsLineCommented(line_num)
    let line = getline(a:line_num)
    " Check if line starts with any comment pattern (after whitespace)
    return line =~ '^\s*\(\/\/\|#\|"\|--\|<!--\|\/\*\)'
endfunction

function! ToggleCommentOperator(type)
    let comment_char = GetCommentChar()

    if a:type == 'line'
        let start_line = line("'[")
        let end_line = line("']")
    elseif a:type == 'char'
        let start_line = line("'[")
        let end_line = line("']")
    else
        return
    endif

    " Check if any line in range is commented
    let has_commented = 0
    for line_num in range(start_line, end_line)
        if IsLineCommented(line_num)
            let has_commented = 1
            break
        endif
    endfor

    if has_commented
        " Uncomment all lines
        execute start_line . ',' . end_line . 's/^\(\s*\)\/\/\s\?/\1/'
        execute start_line . ',' . end_line . 's/^\(\s*\)#\s\?/\1/'
        execute start_line . ',' . end_line . 's/^\(\s*\)"\s\?/\1/'
        execute start_line . ',' . end_line . 's/^\(\s*\)--\s\?/\1/'
        execute start_line . ',' . end_line . 's/^\(\s*\)<!--\s\?/\1/'
        execute start_line . ',' . end_line . 's/^\(\s*\)\/\*\s\?/\1/'
    else
        " Comment all lines
        execute start_line . ',' . end_line . 's/^\(\s*\)/\1' . escape(comment_char, '/') . ' /'
    endif
endfunction

function! ToggleCommentCurrentLine()
    let comment_char = GetCommentChar()

    if IsLineCommented(line('.'))
        " Uncomment current line
        silent! s/^\(\s*\)\/\/\s\?/\1/
        silent! s/^\(\s*\)#\s\?/\1/
        silent! s/^\(\s*\)"\s\?/\1/
        silent! s/^\(\s*\)--\s\?/\1/
        silent! s/^\(\s*\)<!--\s\?/\1/
        silent! s/^\(\s*\)\/\*\s\?/\1/
    else
        " Comment current line
        execute 's/^\(\s*\)/\1' . escape(comment_char, '/') . ' /'
    endif
endfunction

" Toggle comment mappings
nnoremap <silent> gc :set operatorfunc=ToggleCommentOperator<CR>g@
nnoremap <silent> gcc :call ToggleCommentCurrentLine()<CR>


"--------------Helpful Tricks---------------
"ZZ -> Save and close current split window
" ------Movement-------
" Ctrl-o -> Last cursor position
" 0 -> Jump to begin of line
" $ -> Jump to end of line
" Shift-h/m/l -> Jump to top/middle/lower of the page
" g/Shift-g -> Jump to beginning/end of file
" w/b -> Jump to next/prev word
" W/B -> Jump to next/prev word after space
" I -> Jump to first char of line with I_mode
" P -> Jump to last char of line with I_mode
"
" -----Edits-----
" i -> I_mode
" o/Shift-o -> Insert line below/above
" d -> Delete (dw, d$)
" c -> Delete + I_mode (cw, c$)
" x -> delete character (~ dl)
" Ctrl-u -> Undo
" Ctrl-r -> Redo
" . -> repeats the previous command
" :-12t+19<cr> - copy a line 12 lines above cursor and paste 19 lines after
"

"----------------------------- OLD Configs---------------------------------
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  " Improved search colors
  hi Search ctermbg=226 ctermfg=16 guibg=#ffff00 guifg=#000000
  hi IncSearch ctermbg=202 ctermfg=16 guibg=#ff5f00 guifg=#000000
  hi MatchParen ctermbg=208 ctermfg=16 guibg=#ff8700 guifg=#000000

  " Define colors for library-specific syntax highlighting
  hi pythonLibraryFunc ctermfg=cyan guifg=#00ffff
  hi pythonLibraryType ctermfg=magenta guifg=#ff00ff
  hi pythonLibraryConst ctermfg=red guifg=#ff0000
endif
if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window.
  set lines=990 columns=990
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

  autocmd BufRead *.mkd,*.md  set ai formatoptions=tcroqn2 comments=n:>

else


endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                  \ | wincmd p | diffthis
endif

"----------------Enhanced Status Line and UI----------------
" Custom status line
set laststatus=2
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineMode()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\

function! StatuslineMode()
  let l:mode=mode()
  if l:mode==#"n"
    return "NORMAL"
  elseif l:mode==?"v"
    return "VISUAL"
  elseif l:mode==#"i"
    return "INSERT"
  elseif l:mode==#"R"
    return "REPLACE"
  else
    return l:mode
  endif
endfunction

" Better split separators
set fillchars+=vert:│
hi VertSplit ctermfg=236 ctermbg=236 guifg=#3a3a3a guibg=#3a3a3a

" Popup menu colors
hi Pmenu ctermbg=238 ctermfg=255 guibg=#444444 guifg=#ffffff
hi PmenuSel ctermbg=148 ctermfg=16 guibg=#afd700 guifg=#000000
