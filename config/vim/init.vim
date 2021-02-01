" ==============================================================================
" Main Contributor: Syl <shanyouli6@gmail.com>
" Version: 0.1
" Created: 2020-12-21
" Last Modified: 2021-02-01
"
" Sections:
"  -> base config
"  -> xdg Setting
"  -> General
"  -> Vim-Plug
" ==============================================================================
" vim:set ts=4 sw=4 tw=80 noet :

"------------------------------------------------------------------------------
" Base Config
"------------------------------------------------------------------------------

set nocompatible                " 禁用 vi 兼容模式
set bs=eol,start,indent         " 设置 Backspace 键模式
set autoindent                  " 自动缩进
set cindent                     " 打开 C/C++ 语言缩进优化
set winaltkeys=no               " Windows 禁用 ALT 操作菜单（使 ALT 可以在 vim 中使用）
set nowrap                      " 关闭自动换行
set ttimeout                    " 打开超时检测
set ttimeoutlen=50             " 功能键超时时间为 50ms
set ruler                       " 显示光标位置

" 搜索设置"
set ignorecase                  " 搜索时忽略大小写
set smartcase                   " 默认搜索时忽略大小写除非搜索字符包含大小写
set incsearch                   " 查找输入时动态增量显示查找结果
set hlsearch                    " 高亮搜索结果

" 编码设置
if has('multi_byte')
   set encoding=utf-8           " 内部编码
   set fileencoding=utf-8         " 文件默认编码
   set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1 "打开文件自动尝试编码顺序
endif
" 自动缩减
if has('autocmd')
   filetype plugin indent on
endif

" 语法高亮
if has('syntax')
   syntax enable
   syntax on
endif

" 其它设置
set showmatch                   " 显示匹配的括号
set matchtime=2                 " 显示匹配括号的时间
set display=lastline            " 显示最后一行
set wildmenu                    " 允许下方显示目录
set lazyredraw                  " 延时绘制 （提升性能）
set errorformat+=[%f:%l]\ ->\ %m,[%f:%l]:%m " 错误提示格式
set listchars=tab:\|\ ,trail:.,extends:>,precedes:< " 设置分隔符可视

" 设置 tags：当前文件所在目录往上向根目录搜索直到碰到 .tags 文件
" 或者 Vim 当前目录包含 .tags 文件
set tags=./.tags;,.tags

set formatoptions+=m            " 如遇Unicode值大于255的文本，不必等到空格再折行
set formatoptions+=B            " 合并两行中文时，不在中间加空格
set ffs=unix,dos,mac            " 文件换行符，默认使用 unix 换行符

"" 代码折叠
if has('folding')
   set foldenable               " 允许代码折叠
   set fdm=indent               " 代码折叠默认使用缩进
   set foldlevel=99             " 默认打开所有缩进
endif

"" 文件搜索或补全时忽略下面的扩展名
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class

set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib "stuff to ignore when tab completing
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz    " MacOSX/Linux
set wildignore+=*DS_Store*,*.ipch
set wildignore+=*.gem
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/.rbenv/**
set wildignore+=*/.nx/**,*.app,*.git,.git
set wildignore+=*.wav,*.mp3,*.ogg,*.pcm
set wildignore+=*.mht,*.suo,*.sdf,*.jnlp
set wildignore+=*.chm,*.epub,*.pdf,*.mobi,*.ttf
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*.msi,*.crx,*.deb,*.vfd,*.apk,*.ipa,*.bin,*.msu
set wildignore+=*.gba,*.sfc,*.078,*.nds,*.smd,*.smc
set wildignore+=*.linux2,*.win32,*.darwin,*.freebsd,*.linux,*.android

"-----------------------------------------------------------------------------
" XDG Setting
"-----------------------------------------------------------------------------
if empty("$XDG_CACHE_HOME")
   let $XDG_CACHE_HOME="$HOME/.cache"
endif

if empty("$XDG_CONFIG_HOME")
    let $XDG_CONFIG_HOME="$HOME/.config"
endif

if empty("$XDG_DATA_HOME")
    let $XDG_DATA_HOME="$HOME/.local/share"
endif

"-----------------------------------------------------------------------------
" tmux 功能键超时时间
"-----------------------------------------------------------------------------
if $TMUX != ''
    set ttimeoutlen=30
elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
    set ttimeoutlen=80
endif

"-----------------------------------------------------------------------------
" 终端下允许 ALT，详见：http://www.skywind.me/blog/archives/2021
" 记得设置 ttimeout 和 ttimeoutlen
"-----------------------------------------------------------------------------
if has('nvim') == 0 && has('gui_running') == 0
    function! s:metacode(key)
	    exec "set <M-".a:key.">=\e".a:key
    endfunc
    for i in range(10)
	    call s:metacode(nr2char(char2nr('0') + i))
    endfor
    for i in range(26)
	    call s:metacode(nr2char(char2nr('a') + i))
	    call s:metacode(nr2char(char2nr('A') + i))
    endfor
    for c in [',', '.', '/', ';', '{', '}']
	    call s:metacode(c)
    endfor
    for c in ['?', ':', '-', '+', '=', "'"]
        call s:metacode(c)
    endfor
endif

"-----------------------------------------------------------------------------
" 终端下的功能键设置
"-----------------------------------------------------------------------------
function! s:key_escape(name, code)
    if has('nvim') == 0 && has('gui_running') == 0
	    exec "set ".a:name."=\e".a:code
    endif
endfunc
"----------------------------------------------------------------------
" 功能键终端码矫正
"----------------------------------------------------------------------
call s:key_escape('<F1>', 'OP')
call s:key_escape('<F2>', 'OQ')
call s:key_escape('<F3>', 'OR')
call s:key_escape('<F4>', 'OS')
call s:key_escape('<S-F1>', '[1;2P')
call s:key_escape('<S-F2>', '[1;2Q')
call s:key_escape('<S-F3>', '[1;2R')
call s:key_escape('<S-F4>', '[1;2S')
call s:key_escape('<S-F5>', '[15;2~')
call s:key_escape('<S-F6>', '[17;2~')
call s:key_escape('<S-F7>', '[18;2~')
call s:key_escape('<S-F8>', '[19;2~')
call s:key_escape('<S-F9>', '[20;2~')
call s:key_escape('<S-F10>', '[21;2~')
call s:key_escape('<S-F11>', '[23;2~')
call s:key_escape('<S-F12>', '[24;2~')

"----------------------------------------------------------------------
" 防止tmux下vim的背景色显示异常
" Refer: http://sunaku.github.io/vim-256color-bce.html
"----------------------------------------------------------------------
if &term =~ '256color' && $TMUX != ''
	" disable Background Color Erase (BCE) so that color schemes
	" render properly when inside 256-color tmux and GNU screen.
	" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
	set t_ut=
endif

"----------------------------------------------------------------------
" 备份设置
"----------------------------------------------------------------------
set backup  " 允许备份
set writebackup " 保存时备份
set backupext=.bak " 备份时的扩展名
set swapfile " 使用交换文件 noswapfile 不使用
set undofile " 使用 undo文件，noundofile 不使用
" 设置备份文件夹，交换文件夹，undo文件夹，缓存文件夹，会话文件夹 
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
" 一些修改文件信息的保存
set viminfo='10,<100,:100,%,n$XDG_CACHE_HOME/vim/.viminfo

"----------------------------------------------------------------------
" 配置微调
"----------------------------------------------------------------------

" 修正 ScureCRT/XShell 以及某些终端乱码问题，主要原因是不支持一些
" 终端控制命令，比如 cursor shaping 这类更改光标形状的 xterm 终端命令
" 会令一些支持 xterm 不完全的终端解析错误，显示为错误的字符，比如 q 字符
" 如果你确认你的终端支持，不会在一些不兼容的终端上运行该配置，可以注释
" if has('nvim')
	" set guicursor=
if (!has('gui_running')) && has('terminal') && has('patch-8.0.1200')
	let g:termcap_guicursor = &guicursor
	let g:termcap_t_RS = &t_RS
	let g:termcap_t_SH = &t_SH
	set guicursor=
	set t_RS=
	set t_SH=
endif

" 打开文件时恢复上一次光标所在位置
autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\	 exe "normal! g`\"" |
	\ endif

" 定义一个 DiffOrig 命令用于查看文件改动
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
          \ | wincmd p | diffthis
endif



"----------------------------------------------------------------------
" 文件类型微调
"----------------------------------------------------------------------
augroup InitFileTypesGroup

	" 清除同组的历史 autocommand
	au!

	" C/C++ 文件使用 // 作为注释
	au FileType c,cpp setlocal commentstring=//\ %s

	" markdown 允许自动换行
	au FileType markdown setlocal wrap

	" lisp 进行微调
	au FileType lisp setlocal ts=8 sts=2 sw=2 et

	" scala 微调
	au FileType scala setlocal sts=4 sw=4 noet

	" haskell 进行微调
	au FileType haskell setlocal et

	" quickfix 隐藏行号
	au FileType qf setlocal nonumber

	" 强制对某些扩展名的 filetype 进行纠正
	au BufNewFile,BufRead *.as setlocal filetype=actionscript
	au BufNewFile,BufRead *.pro setlocal filetype=prolog
	au BufNewFile,BufRead *.es setlocal filetype=erlang
	au BufNewFile,BufRead *.asc setlocal filetype=asciidoc
	au BufNewFile,BufRead *.vl setlocal filetype=verilog

augroup END


"----------------------------------------------------------------------
" 默认缩进模式（可以后期覆盖）
"----------------------------------------------------------------------
set sw=4 " 设置缩进宽度
set ts=4 " 设置 TAB 宽度
set noet " 禁止展开 tab (noexpandtab)
set softtabstop=4 " 如果后面设置了 expandtab 那么展开 tab 为多少字符

" Python 中 Tab 的特殊设置
augroup PythonTab
	au!
	" 如果你需要 python 里用 tab，那么反注释下面这行字，否则vim会在打开py文件
	" 时自动设置成空格缩进。
	"au FileType python setlocal shiftwidth=4 tabstop=4 noexpandtab
augroup END

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

" General

let mapleader=','         " Change the mapleader
let maplocalleader='\'    " Change the maplocalleader '
set timeoutlen=500              " Time to wait for a command

" Source the vimrc file after saving it
autocmd BufWritePost $MYVIMRC source $MYVIMRC
" Fast edit the .vimrc file using ,x
if isdirectory('/etc/nixos')
  nnoremap <Leader>x :tabedit /etc/nixos/config/vim/init.vim<CR>
else
  nnoremap <leader>x :tabedit $DOTFILES/config/vim/init.vim<CR>
endif

set autoread " Set autoread when a file is changed outside
set autowrite " Write on make/shell commands
set hidden " Turn on hidden"

set history=1000 " Increase the lines of history
set modeline " Turn on modeline
set encoding=utf-8 " Set utf-8 encoding
set completeopt+=longest " Optimize auto complete
set completeopt-=preview " Optimize auto complete


"-------------------------------------------------
" => Platform Specific Setting
"-------------------------------------------------

" On Windows, also use .vim instead of vimfiles
if has('win32') || has('win64')
    set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

set viewoptions+=slash,unix " Better Unix/Windows compatibility
set viewoptions-=options " in case of mapping change

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
