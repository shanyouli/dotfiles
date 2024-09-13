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

fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=path --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(_my_fzf_cmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}

zle     -N             fzf-cd-widget
bindkey -M emacs '\ec' fzf-cd-widget
bindkey -M vicmd '\ec' fzf-cd-widget
bindkey -M viins '\ec' fzf-cd-widget
bindkey '^Xd' fzf-cd-widget

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

# fzf-history-widget
# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m" $(_my_fzf_cmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N            fzf-history-widget

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

# 搜索文件
# 会将 * 或 ** 替换为搜索结果
# 前者表示搜索单层, 后者表示搜索子目录
function fz-find() {
    local selected dir cut
    cut=$(grep -oP '[^* ]+(?=\*{1,2}$)' <<< $BUFFER)
    eval "dir=${cut:-.}"
    if [[ $BUFFER == *"**"* ]] {
        selected=$(fd -H . $dir | ftb-tmux-popup --tiebreak=end,length --prompt="cd> ")
    } elif [[ $BUFFER == *"*"* ]] {
        selected=$(fd -d 1 . $dir | ftb-tmux-popup --tiebreak=end --prompt="cd> ")
    }
    BUFFER=${BUFFER/%'*'*/}
    BUFFER=${BUFFER/%$cut/$selected}
    zle end-of-line
}
zle -N fz-find
bindkey "^[s" fz-find
