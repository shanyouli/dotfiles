# declare -x -A ZINIT=(
#   [HOME_DIR]="$XDG_CACHE_HOME/zinit"
#   [BIN_DIR]="$XDG_CACHE_HOME/zinit/bin"
# )

typeset -gA ZINIT=(
    BIN_DIR         $XDG_CACHE_HOME/zinit/bin
    HOME_DIR        $XDG_CACHE_HOME/zinit
    ZCOMPDUMP_PATH  $ZSH_CACHE
    COMPINIT_OPTS   -C
)
[[ -d "${ZINIT[BIN_DIR]}" ]] || {
    git clone --depth 1 https://github.com/zdharma/zinit "${ZINIT[BIN_DIR]}"
}
source "${ZINIT[BIN_DIR]}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

[[ -d "${ZINIT[COMPLETIONS_DIR]}" ]] || mkdir -p ${ZINIT[COMPLETIONS_DIR]}

# Common ICE modifiers
zt() { zinit depth"1" lucid  ${1/#[0-9][a-c]/wait"$1"} "${@:2}" ; }
# zice() { zinit ice lucid depth'1' "$@" ; }
zice() {
    local _all=( $@ )
    local _wait
    local _package
    if [[ ${_all[1]} == [0-9][a-c] ]]; then
        _wait=wait"${_all[1]}"
        shift _all
    fi
    _package=${_all[-1]}
    zinit ice lucid depth'1' $_wait ${_all:0:-1}
    zinit light $_package
}
zt 0a light-mode for \
    blockf \
        zsh-users/zsh-completions \
    compile'{src/*.zsh,src/strategies/*}' pick'zsh-autosuggestions.zsh' \
    atload'_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions

zt 0b light-mode for \
    compile'{hsmw-*,test/*}' \
        zdharma/history-search-multi-word \
    pick'autopair.zsh' nocompletions atload'bindkey "^H" backward-kill-word;
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
        hlissner/zsh-autopair \
        zsh-users/zsh-history-substring-search

# fast-syntax-highlighting
zice 0b if'[[ -z $SSH_CONNECTION ]]' zdharma/fast-syntax-highlighting

# 为zsh 插件提供man的帮助
#zice has'ruby' zinit-zsh/z-a-man

# fast alias-tips
zice from'gh-r' as'program' sei40kr/fast-alias-tips-bin
zice 0c NICHOLAS85/zsh-fast-alias-tips

# 快速目录跳转
if command -v "lua" >/dev/null ; then
    zice 0c skywind3000/z.lua
    export _ZL_DATA=$XDG_CACHE_HOME/zlua
    export _ZL_ADD_ONCE=1 # 仅当路径更新时，更新数据库
else
    zice 0c agkozak/zsh-z
    export ZSHZ_DATA=$XDG_CACHE_HOME/z
fi
# fzf fzf-tmux
zice if'! command -v fzf >/dev/null' from"gh-r" as"program" junegunn/fzf-bin
zice 0c has"fzf" pick'shell/key-bindings.zsh' \
    atclone"cp -rv shell/completion.zsh ${ZINIT[COMPLETIONS_DIR]}/_fzf" \
    junegunn/fzf
