"
"
" Main Contributor: Syl <shanyouli6@gmail.com>
" Version: 0.1
" Created: 2020-12-21
" Last Modified: 2020-12-21
"
" Sections:
"  -> xdg Setting
"  -> General
"  -> Vim-Plug


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" XDG Setting
if empty("$XDG_CACHE_HOME")
   let $XDG_CACHE_HOME="$HOME/.cache"
endif

if empty("$XDG_CONFIG_HOME")
    let $XDG_CONFIG_HOME="$HOME/.config"
endif

if empty("$XDG_DATA_HOME")
    let $XDG_DATA_HOME="$HOME/.local/share"
endif

" General

set nocompatible "Get out of vi compatible mode
filetype plugin indent on " Enable filetype
let mapleader=','         " Change the mapleader
let maplocalleader='\'    " Change the maplocalleader '
set timeoutlen=500              " Time to wait for a command

" Source the vimrc file after saving it
autocmd BufWritePost $MYVIMRC source $MYVIMRC
" Fast edit the .vimrc file using ,x
nnoremap <Leader>x :tabedit $MYVIMRC<CR>

set autoread " Set autoread when a file is changed outside
set autowrite " Write on make/shell commands
set hidden " Turn on hidden"

set history=1000 " Increase the lines of history
set modeline " Turn on modeline
set encoding=utf-8 " Set utf-8 encoding
set completeopt+=longest " Optimize auto complete
set completeopt-=preview " Optimize auto complete

set undofile " Set undo

" Set directories
function! InitializeDirectories()
  let parent=$XDG_CACHE_HOME
  let prefix='vim'
  let dir_list={
            \ 'backup': 'backupdir',
            \ 'view': 'viewdir',
            \ 'swap': 'directory',
            \ 'undo': 'undodir',
            \ 'cache': '',
            \ 'session': ''}
  for [dirname, settingname] in items(dir_list)
    let directory=parent.'/'.prefix.'/'.dirname.'/'
    if !isdirectory(directory)
      if exists('*mkdir')
        let dir = substitute(directory, "/$", "", "")
        call mkdir(dir, 'p')
      else
        echo 'Warning: Unable to create directory: ' .directory
      endif
    endif
    if settingname!=''
      exe 'set '.settingname.'='.directory
     endif
  endfor
endfunction
call InitializeDirectories()
set viminfo='10,<100,:100,%,n$XDG_CACHE_HOME/vim/.viminfo
"-------------------------------------------------
" => Platform Specific Setting
"-------------------------------------------------

" On Windows, also use .vim instead of vimfiles
" if has('win32') || has('win64')
"     set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
" endif

set viewoptions+=slash,unix " Better Unix/Windows compatibility
set viewoptions-=options " in case of mapping change

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" if empty(glob('~/.vim/autoload/plug.vim'))
"     silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
"                 \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"     autocmd VimEnter * PlugInstall | source $MYVIMRC
" endif

" Vim-Plug install

call plug#begin('$XDG_DATA_HOME/vim/plug')

" Multiple file types
Plug 'kovisoft/paredit', { 'for': ['clojure', 'scheme'] }

call plug#end()
