" Preamble ---------------------------------------------------------------- {{{

filetype off
call pathogen#infect()
filetype plugin indent on
set nocompatible

" }}}

" Basic options ----------------------------------------------------------- {{{

set encoding=utf-8
set modelines=0
set autoindent
set showmode
set showcmd
set hidden
set visualbell
set ruler
set backspace=indent,eol,start
set number
" set relativenumber
set laststatus=2
set history=1000
set undofile
set undoreload=10000
" set list
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set lazyredraw
set matchtime=3
set showbreak=↪
set splitbelow
set splitright
set autowrite
set autoread
set shiftround
set title
set cursorline
set diffopt=filler,iwhite
" set linebreak
" set dictionary=/usr/share/dict/words
" set spellfile=~/.vim/custom-dictionary.utf-8.add
" set colorcolumn=+1
set fillchars=diff:\·,vert:│

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=800

set timeout
" Set mapping delay to 1s so you can think what to type next
set timeoutlen=1000
" Set key code delay to 0.01s
set ttimeoutlen=100

" Set up ins-completions preferences
" set complete=.,w,b,u,t,kspell
set completeopt=longest,menuone

" Resize splits when the window is resized
au VimResized * :wincmd =

let mapleader=' '

" Preview {{{
" Turn off previews once a completion is accepted
" autocmd CursorMovedI *  if pumvisible() == 0|silent! pclose|endif
" autocmd InsertLeave * if pumvisible() == 0|silent! pclose|endif
" }}}

" Cursorline {{{
" Only show cursorline in the current window and in normal mode.
" augroup cline
"     au!
"     au WinLeave,InsertEnter * set nocursorline
"     au WinEnter,InsertLeave * set cursorline
" augroup END

" }}}

" cpoptions+=J {{{
" A |sentence| has to be followed by two spaces after the '.', '!' or '?'.  A <Tab> is not recognized as white space.
" augroup twospace
"     au!
"     au BufRead * :set cpoptions+=J
" augroup END

" }}}

" Trailing whitespace {{{
" Only shown when not in insert mode so I don't go insane.
augroup trailing
    au!
    au InsertEnter * :set listchars-=trail:⋅
    au InsertLeave * :set listchars+=trail:⋅
augroup END
" }}}

" Wildmenu completion {{{
set wildmenu
set wildmode=list:longest
set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX files
set wildignore+=*.luac                           " Lua byte code
set wildignore+=migrations                       " Django migrations
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.orig                           " Merge resolution files
" }}}

" Line Return {{{
" Make sure Vim returns to the same line when you reopen a file.
augroup line_return
    au!
    au BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"' |
        \ endif
augroup END
" }}}

" Tabs, spaces, wrapping {{{
set tabstop=8
set shiftwidth=4
set softtabstop=4
set expandtab
set wrap
set textwidth=80
set formatoptions=qrn1cl
" }}}

" Backups {{{
set backup                        " enable backups
set noswapfile                    " it's 2013, Vim.
set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif
" }}}

" Color scheme {{{
syntax on
" set background=dark
colorscheme trafficlights

" Reload the colorscheme whenever we write the file.
augroup color_trafficlights_dev
    au!
    au BufWritePost trafficlights.vim color trafficlights
augroup END
" }}}

" Tabline {{{
if exists("+showtabline")
  function! MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
      " set up some oft-used variables
      let tab = i + 1 " range() starts at 0
      let winnr = tabpagewinnr(tab) " gets current window of current tab
      let buflist = tabpagebuflist(tab) " list of buffers associated with the windows in the current tab
      let bufnr = buflist[winnr - 1] " current buffer number
      let bufname = bufname(bufnr) " gets the name of the current buffer in the current window of the current tab

      let s .= '%' . tab . 'T' " start a tab
      let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#') " if this tab is the current tab...set the right highlighting
      let s .= ' ' . tab " current tab number
      let n = tabpagewinnr(tab,'$') " get the number of windows in the current tab
      if n > 1
        let s .= ':' . n " if there's more than one, add a colon and display the count
      endif
      let bufmodified = ''
      " getbufvar(bufnr, "&mod")
      for b in buflist
        if getbufvar(b, "&mod")
          let bufmodified = 1
          break
        endif
      endfor
      if bufmodified
        let s .= ' +'
      endif
      if bufname != ''
        let s .= ' ' . pathshorten(bufname) . ' ' " outputs the one-letter-path shorthand & filename
      else
        let s .= ' [No Name] '
      endif
      if tab == tabpagenr()
          let s .= '%999X x '
      else
          let s .= '   '
      endif
    endfor
    let s .= '%#TabLineFill#' " blank highlighting between the tabs and the righthand close 'X'
    let s .= '%T' " resets tab page number?
    let s .= '%=' " seperate left-aligned from right-aligned
    " let s .= '%#TabLine#' " set highlight for the 'X' below
    " let s .= '%999XX' " places an 'X' at the far-right
    return s
  endfunction
  set tabline=%!MyTabLine()
endif
" }}}

function! Status(focused)
  let stat = ''

  " this function just outputs the content colored by the
  " supplied colorgroup number, e.g. num = 2 -> User2
  " it only colors the input if the window is the currently
  " focused one
  function! Color(active, num, content)
    if a:active
      return '%' . a:num . '*' . a:content . '%*'
    else
      return a:content
    endif
  endfunction

  " column
  " this might seem a bit complicated but all it amounts to is
  " a calculation to see how much padding should be used for the
  " column number, so that it lines up nicely with the line numbers

  " an expression is needed because expressions are evaluated within
  " the context of the window for which the statusline is being prepared
  " this is crucial because the line and virtcol functions otherwise
  " operate on the currently focused window

  function! ColPad()
    let ruler_width = max([strlen(line('$')), (&numberwidth - 1)])
    let column_width = strlen(virtcol('.'))
    let padding = ruler_width - column_width

    redir =>a|exe "sil sign place buffer=".bufnr('')|redir end
    let signs = split(a, "\n")[1:]
    if !empty(signs)
        let padding = padding + 2
    endif

    if &foldcolumn!=''
        let padding = padding + &foldcolumn
    endif

    if padding <= 0
      return ''
    else
      " + 1 becuase for some reason vim eats one of the spaces
      return repeat(' ', padding + 1)
  endfunction

  let stat .= '%{ColPad()}'
  let stat .= '%v'
  let stat .= ' %<'
  let stat .= ' %2n: %F'
  let stat .= "     "
  let stat .= "%m"
  let stat .= "%r"
  let stat .= "%w"
  let stat .= "%q"
  let stat .= "%y"
  let stat .= "%{&diff ? '[diff]' : ''}"
  let stat .= '%='
  if &paste
    let stat .= '[paste]'
  endif
  let stat .= "%{exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}"
  let stat .= "%{exists('g:loaded_fugitive')?fugitive#statusline():''}"
  let stat .= "     [%{exists('g:scrollbar_loaded')?ScrollBar(20,' ','='):''}]"
  return stat
endfunction

augroup status
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setl statusline=%!Status(1)
  autocmd WinLeave * setl statusline=%!Status(0)
augroup END

autocmd VimEnter,WinEnter,BufWinEnter * set statusline=%!Status(1)

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" }}}

" Abbreviations ----------------------------------------------------------- {{{

iabbrev gcavn@ gcavn@gcavn.com

" }}}

" Convenience mappings ---------------------------------------------------- {{{

" Easy window resizing
nnoremap <silent> <C-W><C-Up> 10<c-w>+
nnoremap <silent> <C-W><C-down> 10<c-w>-
nnoremap <silent> <C-W><C-left> 10<c-w><
nnoremap <silent> <C-W><C-right> 10<c-w>>

nnoremap <silent> <leader>/ :execute 'vimgrep /' . @/ . '/g %'<CR>:copen<CR>

" nnoremap <c-z> mzzMzvzz15<c-e>`z:Pulse<cr>
nnoremap <leader>d "_d
vnoremap <leader>d "_d

command! -range=% SoftWrap <line2>put _ | <line1>,<line2>g/.\+/ .;-/^$/ join |normal $x

" Kill window
nnoremap <leader>q :confirm qa<cr>

" Write buffer to file
nnoremap <leader>w :w<cr>

" inoremap <C-j> <esc>
" set <F13>=jk
" imap <F13> <esc>
" set <F14>=kj
" imap <F14> <esc>

" Tabs
" a tab is short Strip of material attached to something
nnoremap [s :tabprev<cr>
nnoremap ]s :tabnext<cr>
nnoremap ]S :tablast<cr>
nnoremap [S :tabfirst<cr>

" Make Y move like D and C
noremap Y y$

" Rebuild Ctags (mnemonic RC -> CR -> <cr>)
" nnoremap <leader><cr> :silent !myctags<cr>:redraw!<cr>

" Clean trailing whitespace
" nnoremap <leader>w mz:%s/\s\+$//<cr>:let @/=''<cr>`z

nnoremap <F3> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Select entire buffer
nnoremap vaa ggvGg_
nnoremap Vaa ggVG

" Easier linewise reselection of what you just pasted.
nnoremap <leader>V V`]

" Indent/dedent/autoindent what you just pasted.
nnoremap <lt>> V`]<
nnoremap ><lt> V`]>
nnoremap =- V`]=

" Source
vnoremap <leader>S y:execute @@<cr>:echo 'Sourced selection.'<cr>
nnoremap <leader>S ^vg_y:execute @@<cr>:echo 'Sourced line.'<cr>

" Directional Keys
noremap j gj
noremap k gk
noremap gj j
noremap gk k

" Easier forward delete
" inoremap <c-l> <Del>

" Switch inner word caSe
inoremap <C-s> <esc>mzg~iw`za

" }}}

" Quick editing ----------------------------------------------------------- {{{

nnoremap <leader>eh :e ~/.<cr>
nnoremap <leader>ef :e %:p:h<cr>
nnoremap <leader>e. :e .<cr>

" }}}

" Searching and movement -------------------------------------------------- {{{

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

set ignorecase
set smartcase
set incsearch
set showmatch
" set hlsearch
set gdefault

set scrolloff=3
set sidescroll=1
set sidescrolloff=10

" }}}

" Folding ----------------------------------------------------------------- {{{

set foldlevelstart=99

" }}}

" Filetype-specific ------------------------------------------------------- {{{

" Bash {{{

augroup ft_bash
    au!
    au BufNewFile,BufRead *.sh setlocal filetype=zsh
    au FileType sh let b:is_bash=1
    au FileType sh setlocal filetype=zsh
augroup END

" }}}

" C {{{

augroup ft_c
    au!
    au FileType c setlocal foldmethod=marker foldmarker={,}
augroup END

" }}}

" CSS and LessCSS {{{

augroup ft_css
    au!

    au BufNewFile,BufRead *.less setlocal filetype=less

    au Filetype less,css setlocal foldmethod=marker
    au Filetype less,css setlocal foldmarker={,}
    au Filetype less,css setlocal omnifunc=csscomplete#CompleteCSS
    au Filetype less,css setlocal iskeyword+=-

    " Use <leader>S to sort properties.  Turns this:
    "
    "     p {
    "         width: 200px;
    "         height: 100px;
    "         background: red;
    "
    "         ...
    "     }
    "
    " into this:

    "     p {
    "         background: red;
    "         height: 100px;
    "         width: 200px;
    "
    "         ...
    "     }
    au BufNewFile,BufRead *.less,*.css nnoremap <buffer> <localleader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>

    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
    " positioned inside of them AND the following code doesn't get unfolded.
    "    au BufNewFile,BufRead *.less,*.css inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>
augroup END

" }}}

" Java {{{

augroup ft_java
    au!

    au FileType java setlocal foldmethod=marker
    au FileType java setlocal foldmarker={,}
augroup END

" }}}

" Javascript {{{
augroup ft_javascript
    au!

    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
"
"    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
"    " positioned inside of them AND the following code doesn't get unfolded.
"    au Filetype javascript inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>
augroup END
" }}}

" Markdown {{{
augroup ft_markdown
    au!

    au BufNewFile,BufRead {*.md,*.mkd,*.markdown} setlocal filetype=markdown foldlevel=1

augroup END
" }}}

" Postgresql {{{
augroup ft_postgres
    au!

    au BufNewFile,BufRead *.sql set filetype=pgsql
    au FileType pgsql set foldmethod=indent
    au FileType pgsql set softtabstop=2 shiftwidth=2
    au FileType pgsql setlocal commentstring=--\ %s comments=:--
augroup END
" }}}

" QuickFix {{{
augroup ft_quickfix
    au!
    au Filetype qf setlocal colorcolumn=0 nolist nocursorline nowrap tw=0
augroup END
" }}}

" Text {{{
augroup ft_text
    au!
    au FileType text setlocal spell fo=t1
    au InsertEnter *.txt setlocal fo+=a
    au InsertLeave *.txt setlocal fo-=a
    au FileType text inoremap <buffer> . .<C-G>u
    au FileType text inoremap <buffer> , ,<C-G>u
    au FileType text inoremap <buffer> ! !<C-G>u
    au FileType text inoremap <buffer> ? ?<C-G>u
augroup END
" }}}

" Vim {{{
augroup ft_vim
    au!

    au FileType vim setlocal foldmethod=marker
    au FileType help setlocal textwidth=78
    au FileType vim setlocal formatoptions=qrn1cl
    " au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END
" }}}

" Python {{{
augroup ft_python
    au!

    au FileType python set foldmethod=expr
    au FileType python set foldexpr=g:Pymodefoldingexpr(v:lnum)
    au FileType python set omnifunc=pythoncomplete#Complete
augroup END
" }}}

" YAML {{{
augroup ft_yaml
    au!

    au FileType yaml set shiftwidth=2
augroup END
" }}}

" XML {{{
augroup ft_xml
    au!

    au FileType xml setlocal foldmethod=manual
augroup END
" }}}

" }}}

" Plugin settings --------------------------------------------------------- {{{

" Hardtime {{{
nnoremap <leader>H :HardTimeToggle<CR>
" }}}

" DelimitMate {{{
let delimitMate_expand_cr = 1
" }}}

" Ctrl-P {{{
let g:ctrlp_reuse_window = 'netrw\|help\|quickfix'
let g:ctrlp_cmd = 'CtrlPBuffer'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_match_window = 'order:ttb,max:20'

" StatusLine:
" Arguments: focus, byfname, s:regexp, prv, item, nxt, marked
" a:1 a:2 a:3 a:4 a:5 a:6 a:7
fu! CtrlP_main_status(...)
  let regex = a:3 ? '%*regex %*' : ''
  let byfname = '%* '.a:2.' %*'
  let dir = '%* ' . fnamemodify(getcwd(), ':~') . '%* '
  let prv = '%* '.a:4.' %*'
  let item = ' ' . (a:5 == 'mru files' ? 'mru' : a:5) . ' '
  let nxt = '%* '.a:6.' %*'

  " only outputs current mode
  " retu ' %4*»%*' . item . '%4*«%* ' . '%=%<' . dir

  " outputs previous/next modes as well
  " retu prv . '»' . item . '«' . nxt . '%=%<' . dir
  retu '   ' . item . '%=%<' . dir
endf

" Argument: len
" a:1
fu! CtrlP_progress_status(...)
  let len = '%* '.a:1.' %*'
  let dir = ' %=%<%* '.getcwd().' %*'
  retu len.dir
endf

let g:ctrlp_status_func = {
  \ 'main': 'CtrlP_main_status',
  \ 'prog': 'CtrlP_progress_status'
  \}
" }}}

" Tagbar {{{
" let g:tagbar_iconchars = ['+','-']
let g:tagbar_iconchars = ['▸', '▾']
let g:tagbar_compact = 1
let g:tagbar_sort = 0
let g:tagbar_indent = 2
let g:tagbar_left = 1
let g:tagbar_foldlevel = 0
nnoremap <silent> <F9> :TagbarToggle<CR>
" }}}

" Fugitive {{{
augroup ft_fugitive
    au!

    au BufNewFile,BufRead .git/index setlocal nolist
augroup END
" }}}

" Linediff {{{
vnoremap <leader>l :Linediff<cr>
nnoremap <leader>L :LinediffReset<cr>
" }}}

" Vimux {{{
let g:VimuxRunnerType="window"

function! VimuxSlime()
    call VimuxSendText(@v)
    call VimuxSendKeys("Enter")
endfunction

" If text is selected, save it in the v buffer and send that buffer it to tmux
vmap <leader>vs "vy :call VimuxSlime()<CR>

" Select current paragraph and send it to tmux
nmap <leader>vs vip<LocalLeader>vs<CR>
" }}}

" Syntastic {{{
let g:syntastic_check_on_open=0
nnoremap <leader>C :SyntasticCheck<cr>
" }}}

" vim-unimpaired {{{

" nnoremap <silent> <Plug>unimpairedTabLeft   :tabNext<CR>
" nnoremap <silent> <Plug>unimpairedTabRight  :tabnext<CR>
" xnoremap <silent> <Plug>unimpairedTabLeft   :tabNext<CR>
" xnoremap <silent> <Plug>unimpairedTabRight  :tabnext<CR>

" nmap [g <Plug>unimpairedTabLeft
" nmap ]g <Plug>unimpairedTabRight
" xmap [g <Plug>unimpairedTabLeft
" xmap ]g <Plug>unimpairedTabRight

" nnoremap <silent> <Plug>unimpairedTabFirst   :tabfirst<CR>
" nnoremap <silent> <Plug>unimpairedTabLast    :tablast<CR>
" xnoremap <silent> <Plug>unimpairedTabFirst   :tabfirst<CR>
" xnoremap <silent> <Plug>unimpairedTabLast    :tablast<CR>

" nmap [G <Plug>unimpairedTabFirst
" nmap ]G <Plug>unimpairedTabLast
" xmap [G <Plug>unimpairedTabFirst
" xmap ]G <plug>unimpairedTabLast

" }}}

" undotree ---------------------------------------------------------------- {{{
nnoremap <F5> :UndotreeToggle<cr>
let g:undotree_WindowLayout = 4
let g:undotree_SplitWidth = 50
let g:undotree_DiffCommand = "diff --context=1"
let g:undotree_DiffpanelHeight = 20

" }}}

" indent-guides ----------------------------------------------------------- {{{
let g:indent_guides_auto_colors = 0
" }}}

" jedi -------------------------------------------------------------------- {{{
let g:jedi#auto_vim_configuration = 0
autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#use_tabs_not_buffers = 0
let g:jedi#show_call_signatures = 0
let g:jedi#auto_close_doc = 0
 " }}}

" neocomplete -------------------------------------------------------------------- {{{
" NEOCOMPLCACHE SETTINGS
" let g:neocomplcache_enable_at_startup = 1
" imap neosnippet#expandable() ? "(neosnippet_expand_or_jump)" : pumvisible() ? "" : ""
" smap neosnippet#expandable() ? "(neosnippet_expand_or_jump)" :
" if !exists('g:neocomplcache_omni_functions')
"   let g:neocomplcache_omni_functions = {}
" endif
" if !exists('g:neocomplcache_force_omni_patterns')
"   let g:neocomplcache_force_omni_patterns = {}
" endif
" " let g:neocomplcache_force_overwrite_completefunc = 1
" let g:neocomplcache_force_omni_patterns['python'] = '[^. t].w*'
" set ofu=syntaxcomplete#Complete
" au FileType python set omnifunc=pythoncomplete#Complete
" au FileType python let b:did_ftplugin = 1
" " Vim-jedi settings
" let g:jedi#popup_on_dot = 0

let g:neocomplete#enable_at_startup = 1
" let g:neocomplete#enable_smart_case = 1
let g:neocomplete#enable_auto_select = 0
" let g:neocomplete#disable_auto_complete = 1
" let g:neocomplcache_force_omni_patterns['python'] = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
" imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
" let g:neocomplcache_force_omni_patterns['python'] = '[^. t].w*'
" imap <expr> <CR> pumvisible() ? "\<c-y>" : "<Plug>delimitMateCR"
" inoremap <expr><CR>  pumvisible() ? neocomplete#close_popup() : "\<Plug>delimitMateCR"
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  " return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <expr><C-Space> neocomplete#start_manual_complete()
imap <C-@> <C-Space>
" SuperTab like snippets behavior.
let g:neocomplete#force_omni_input_patterns = {}
let g:neocomplete#force_omni_input_patterns.python = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
let g:neocomplete#force_omni_input_patterns.javascript = '[^. \t]\.\w*'

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" if has('conceal')
"     set conceallevel=2 concealcursor=i
" endif

" }}}

" marching -------------------------------------------------------------------- {{{
let g:marching_enable_neocomplete = 1
let g:marching_backend = "sync_clang_command"
let g:marching_debug = 1

" set updatetime=200
" imap <buffer> <C-x><C-o> <Plug>(marching_start_omni_complete)
" imap <buffer> <C-x><C-x><C-o> <Plug>(marching_force_start_omni_complete)
" let g:neocomplete#sources#omni#input_patterns = {}
" let g:neocomplete#sources#omni#input_patterns.cpp = '[^. *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
let g:neocomplete#force_omni_input_patterns.cpp = '[^. *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
" }}}

" }}}

" Miniplugins ------------------------------------------------------------ {{{

" Diff orig {{{
command DiffOrig let g:diffline = line('.') | vert new | set bt=nofile | r # | 0d_ | diffthis | :exe "norm! ".g:diffline."G" | wincmd p | diffthis | wincmd p
nnoremap <Leader>do :DiffOrig<cr>
nnoremap <leader>dc :q<cr>:diffoff<cr>:exe "norm! ".g:diffline."G"<cr>
" }}}

" Synstack {{{

" Show the stack of syntax hilighting classes affecting whatever is under the
" cursor.
function! SynStack()
  echo join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), " > ")
endfunc

nnoremap <F2> :call SynStack()<CR>

" }}}

" Pulse Line {{{
function! s:Pulse()
    redir => old_hi
        silent execute 'hi CursorLine'
    redir END
    let old_hi = split(old_hi, '\n')[0]
    let old_hi = substitute(old_hi, 'xxx', '', '')

    let steps = 8
    let width = 1
    let start = width
    let end = steps * width
    let color = 233

    for i in range(start, end, width)
        execute "hi CursorLine ctermbg=" . (color + i)
        redraw
        sleep 36m
    endfor
    for i in range(end, start, -1 * width)
        execute "hi CursorLine ctermbg=" . (color + i)
        redraw
        sleep 36m
    endfor

    execute 'hi ' . old_hi
endfunction
command! -nargs=0 Pulse call s:Pulse()
" }}}

" Diff Last Saved {{{
function! s:MyDiffLastSaved()
  if &modified
    let winnum = winnr()
    let filetype=&ft
    vertical botright new | r #
    1,1delete _

    diffthis
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal nobuflisted
    setlocal noswapfile
    setlocal readonly
    exec "setlocal ft=" . filetype
    let diffnum = winnr()

    augroup diff_saved
      autocmd! BufUnload <buffer>
      autocmd BufUnload <buffer> :diffoff!
    augroup END

    " exec winnum . "winc w"
    " diffthis

    " for some reason, these settings only take hold if set here.
    call setwinvar(diffnum, "&foldmethod", "diff")
    call setwinvar(diffnum, "&foldlevel", "0")
  else
    echo "No changes"
  endif
endfunction
command! -nargs=0 MyDiffLastSaved call s:MyDiffLastSaved()

" }}}

" Python-mode folding functions {{{
let g:def_regex = '^\s*\%(class\|def\) \w\+'
let g:blank_regex = '^\s*$'
let g:decorator_regex = '^\s*@'
let g:doc_begin_regex = '^\s*\%("""\|''''''\)'
let g:doc_end_regex = '\%("""\|''''''\)\s*$'
let g:doc_line_regex = '^\s*\("""\|''''''\).\+\1\s*$'
let g:symbol = matchstr(&fillchars, 'fold:\zs.')  " handles multibyte characters
if g:symbol == ''
    let g:symbol = ' '
endif

" fun! g:pymodefoldingtext() " {{{
"     let fs = v:foldstart
"     while getline(fs) =~ '\%(^\s*@\)\|\%(^\s*\%("""\|''''''\)\s*$\)'
"         let fs = nextnonblank(fs + 1)
"     endwhile
"     let line = getline(fs)

"     let nucolwidth = &fdc + &number * &numberwidth
"     let windowwidth = winwidth(0) - nucolwidth - 6
"     let foldedlinecount = v:foldend - v:foldstart

"     " expand tabs into spaces
"     let onetab = strpart('          ', 0, &tabstop)
"     let line = substitute(line, '\t', onetab, 'g')

"     let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
"     let line = substitute(line, '\%("""\|''''''\)', '', '')
"     let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
"     return line . '…' . repeat(g:symbol, fillcharcount) . ' ' . foldedlinecount . ' '
" endfunction "}}}

fun! g:Pymodefoldingexpr(lnum) "{{{

    let line = getline(a:lnum)
    let indent = indent(a:lnum)
    let prev_line = getline(a:lnum - 1)

    if line =~ g:def_regex || line =~ g:decorator_regex
        if prev_line =~ g:decorator_regex
            return '='
        else
            return ">".(indent / &shiftwidth + 1)
        endif
    endif

    if line =~ g:doc_begin_regex && line !~ g:doc_line_regex && prev_line =~ g:def_regex
        return ">".(indent / &shiftwidth + 1)
    endif

    if line =~ g:doc_end_regex && line !~ g:doc_line_regex
        return "<".(indent / &shiftwidth + 1)
    endif

    if line =~ g:blank_regex
        if prev_line =~ g:blank_regex
            if indent(a:lnum + 1) == 0 && getline(a:lnum + 1) !~ g:blank_regex
                return 0
            endif
            return -1
        else
            return '='
        endif
    endif

    if indent == 0
        return 0
    endif

    return '='

endfunction "}}}
" }}}

" }}}

" Environments (GUI/Console) ---------------------------------------------- {{{

if has('gui_running')
    if has("gui_macvim")

    else

    end
else
    set mouse=a
    set clipboard=unnamed
    if &term =~ '^screen'

        " tmux knows the extended mouse mode
        set ttymouse=xterm2

        " change cursor shape when switching from normal to insert mode and back
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

        " support for shift + arrow keys
        execute "set <xUp>=\e[1;*A"
        execute "set <xDown>=\e[1;*B"
        execute "set <xRight>=\e[1;*C"
        execute "set <xLeft>=\e[1;*D"
    else
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    endif
endif

" }}}
