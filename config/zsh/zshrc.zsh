# TMUX config , 当 TMUX_AUTOSTART=True,不在emacs，vim，inter执行zsh时，自动启动tmux
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/tmux/tmux.plugin.zsh
if [[ -z $TMUX && "$TMUX_AUTOSTART" == "True" && -z "$INSIDE_EMACS" && -z $EMACS && -z $VIM && -z "$INTELLIJ_ENVIRONMENT_READER" && $- == *i* ]]; then
    if (( $+commands[tmux] )); then
        if tmux has-session -t TMUX >/dev/null 2>&1; then
            exec tmux attach -t TMUX
        else
            exec tmux new -s TMUX -- "export SHELL=$(which zsh); zsh -il"
        fi
    fi
fi

if [[ -n $TMUX ]]; then
   export FZF_TMUX=1
fi

function _zt { zinit depth"1" lucid ${1/#[0-9][a-c]/wait"$1"} "${@:2}"; }

function _zsnippet() {
    local second
    if [[ $1 == [0-9][a-c] ]]; then
        second=wait"$1"
        shift
    fi
    for i in "$@"; do
        zinit ice silent "$second" ; zinit snippet "$i"
    done
}
function _zice {
  local _all=( "$@" )
  local _wait
  local _package
  if [[ ${_all[1]} == [0-9][a-c] ]]; then
  _wait=wait"${_all[1]}"
  shift _all
  fi
  _package=${_all[-1]}
  zinit ice lucid depth'1' $_wait ${_all:0:-1}
  zinit load $_package
}

# ============ 加载函数 ====
fpath+=(${ZDOTDIR}/completions)
fpath+=(${ZDOTDIR}/functions)

autoload -Uz ${ZDOTDIR}/functions/*(:t)
autoload +X zman
autoload -Uz zmv

# =============== 配置插件 =============

# ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
# ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_COMPLETION_IGNORE='( |man |pikaur -S )*'
ZSH_AUTOSUGGEST_HISTORY_IGNORE='?(#c50,)'
#

# == gencomp
GENCOMP_DIR=$XDG_CONFIG_HOME/zsh/completions

# == zce.zsh
zstyle ':zce:*' keys 'asdghklqwertyuiopzxcvbnmfj;23456789'

# == fzf-tab
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:kill:*' popup-pad 0 3
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
zstyle ":fzf-tab:*" fzf-flags --color=bg+:23
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:exa' sort false
zstyle ':completion:files' sort false

# ==== 加载插件 ====
_zt 0b light-mode for \
    pick'autopair.zsh' nocompletions atload'bindkey "^H" backward-kill-word;
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
      hlissner/zsh-autopair

# alias 提示
_zice 0c atload'YSU_MESSAGE_POSITION="after"' MichaelAquilina/zsh-you-should-use

_zt 0b lucid light-mode for \
    hchbaw/zce.zsh \
    Aloxaf/gencomp
# wfxr/forgit

_zt light-mode for \
    blockf \
    zsh-users/zsh-completions \
    as="program" atclone="rm -f ^(rgg|agv)" \
    lilydjwg/search-and-view \
    src="etc/git-extras-completion.zsh" \
    tj/git-extras

# ==== 某些比较特殊的插件 ====
autoload -Uz compinit && compinit -u -d $ZSH_CACHE/zcompdump
zpcompinit
zpcdreplay

for i in $ZDOTDIR/snippets/*.zsh; do
    source $i
done

# _zsnippet "0a" $ZDOTDIR/plugins/*.plugin.zsh(:)
for i in $ZDOTDIR/plugins/*.plugin.zsh; do
  source $i
done

# ==== 加载并配置 fzf-tab ====

# https://github.com/Aloxaf/fzf-tab/issues/176
# fzf-tab 补全会导致ffmpeg -i <按tab> 崩溃
_zice "0c" atpull'!git rest --hard' \
    atclone"sed -i '/^ *COLUMNS=500 /s/COLUMNS=500 //' fzf-tab.zsh" \
    nocompile blockf Aloxaf/fzf-tab

# ==== ====

# https://blog.lilydjwg.me/2015/7/26/a-simple-zsh-module.116403.html
#zmodload aloxaf/subreap
#subreap

set_fast_theme() {
    FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}alias]='fg=blue'
    FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}function]='fg=blue'
    # 对 man 的高亮会卡住上下翻历史的动作
    # FAST_HIGHLIGHT[chroma-man]=
}

_zt light-mode for \
    if'[[ -z $SSH_CONNECTION ]]' atinit='zpcompinit' atload="set_fast_theme" \
    zdharma/fast-syntax-highlighting \
    compile'{src/*.zsh,src/strategies/*}' pick'zsh-autosuggestions.zsh' \
    atload'_zsh_autosuggest_start' \
    zsh-users/zsh-autosuggestions
