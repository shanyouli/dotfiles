#!/usr/bin/env zsh

_my_fzf_cmd() {
    [ -n "${TMUX_PANE-}" ] && {
        [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]
    } && echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

__my_pscmd() {
    if [ "$UID" != "0" ]; then
        echo "ps -f -u $UID"
    else
        echo "ps -ef"
    fi
}

fzf-kill() {
    local _killOption
    local __query
    if [ "$1" =~ ^[[:digit:]]$ ]; then
        _killOption="$1"
        if [[ -n $2 ]]; then
            __query=$2
        fi
    else
        __query="$1"
    fi
    pid=$($(__my_pscmd) | sed 1d | $(_my_fzf_cmd) -m --border=sharp \
        --prompt="➤  " --pointer="➤ "\
        --marker="➤ " --query=${__query:-""}\
        | awk '{print $2}')

    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${_killOption:-9}
    fi
}

fzf-kill-widget() {
    fzf-kill ${BUFFER}
    zle reset-prompt
    zle beginning-of-line
    zle kill-whole-line
}

zle -N fzf-kill-widget
bindkey '^X^K' fzf-kill-widget

zle -N fzf-cd-widget
bindkey '^X^D' fzf-cd-widget

__my_fzf_select_file() {
    local _query="$1"
    local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune     -o -type f -print     -o -type d -print     -o -type l -print 2> /dev/null | cut -b3-"}"
    setopt localoptions pipefail no_aliases 2> /dev/null
    local item=$(eval "$cmd" \
        | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} \
        --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} \
        ${FZF_CTRL_T_OPTS-}" \
        $(_my_fzf_cmd) -m --query="$_query")
    if [[ -n $item ]]; then
        echo "$item"
    fi
}

fzf-edit-file() {
    local item=$(__my_fzf_select_file $1)
    if [[ -z $item ]]; then
        echo "no find file"
    else
        if [[ -n $EDITOR ]]; then
            $EDITOR "${item}"
        elif (( $+commands[nvim] )); then
            nvim "${item}"
        else
            vim "${item}"
        fi
    fi
}

fzf-edit-file-widget() {
    if [[ -n $EDITOR ]]; then
        cmd="$EDITOR"
    elif (( $+commands[nvim] )); then
        cmd="nvim"
    else
        cmd="vim"
    fi
    local item=$(__my_fzf_select_file $BUFFER)
    if [[ -z $item ]]; then
        zle push-line
        LBUFFER="echo no find file"
        zle accept-line
    else
        # eval "$cmd $(__my_fzf_select_file ${LBUFFER})"
        eval "$cmd \"$item\""
        zle reset-prompt
        zle beginning-of-line
        zle kill-whole-line
    fi
}
zle -N fzf-edit-file-widget
bindkey '^X^F' fzf-edit-file-widget

# @see https://www.hergenhahn-web.de/fzf_gopass.html
pass() {
    if ! (( $+commands[gopass] )); then
        echo "Please Install gopass"
        return 1
    fi
    QUERY=$1
    if [ -z "$QUERY" ]; then
        QUERY=''
    fi
    gopass show -c \
        $(gopass ls --flat \
        | fzf -q "$QUERY" --height 10)
}
[[ -n $INSIDE_EMACS ]] || {
    # https://github.com/Aloxaf/fzf-tab/issues/176
    # fzf-tab 补全会导致ffmpeg -i <按tab> 崩溃
    zinit ice wait lucid depth"1" atload"zicompinit; zicdreplay;" \
        atpull'!git rest --hard' \
        atclone"sed -i '/^ *COLUMNS=500 /s/COLUMNS=500 //' fzf-tab.zsh" \
        nocompile blockf
    zinit light Aloxaf/fzf-tab
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:complete:*:options' sort false
    zstyle ':fzf-tab:complete:(cd|ls|exa|eza|bat|cat|emacs|nano|vi|vim):*' \
        fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
        fzf-preview 'echo ${(P)word}'

    # Preivew `kill` and `ps` commands
    zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'
    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
        '[[ $group == "[process ID]" ]] &&
        if [[ $OSTYPE == darwin* ]]; then
          ps -p $word -o comm="" -w -w
        elif [[ $OSTYPE == linux* ]]; then
          ps --pid=$word -o cmd --no-headers -w -w
        fi'
    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'
}
