#!/usr/bin/env bash
# shellcheck disable=SC2034
CONF="$TMUX_PLUGINS_PATH/lastpane"

swap() { tmux swap-pane -s"$1" -t"$2"; }
tmsp() {
    local panes current_window current_pane target target_window target_pane
    panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
    current_pane=$(tmux display-message -p '#I:#P')
    current_window=$(tmux display-message -p '#I')

    target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

    target_window=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print $1}')
    target_pane=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print $2}' | cut -c 1)

    if [[ $current_window -eq $target_window ]]; then
        tmux select-pane -t "${target_window}"."${target_pane}"
    else
        tmux select-pane -t "${target_window}"."${target_pane}" &&
            tmux select-window -t "$target_window"
    fi
}
target=
case $1 in
up) target="U" ;;
down) target="D" ;;
left) target="L" ;;
right) target="R" ;;
master) target="M" ;;
switch) target="switch" ;;
*) exit 1 ;;
esac

if [[ $target == "switch" ]]; then
    if type fzf >/dev/null 2>&1; then
        tmsp
    else
        tmux choose-window
    fi
else
    src_pane=$(tmux display-message -p "#P")
    tmux select-pane -"${target}"

    dst_pane=$(tmux display-message -p "#P")
    tmux select-pane -"${src_pane}"

    [[ $target == M ]] && dst_pane=0
    swap "$src_pane" "$dst_pane"

    tmux select-pane -t "$dst_pane"
fi
