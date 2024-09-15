function kittenr() {
    local pid=$(ps -eo pid,ppid,start,command |
        grep -E '^[[:space:]]*[0-9]+[[:space:]]+1[[:space:]]+' |
        grep -i -e 'kitty' | grep -v grep |
        sort -k 3 -r | head -1 | awk '{print $1}')
    if [[ -e /tmp/mykitty-${pid} ]]; then
        kitten @ --to unix:/tmp/mykitty-${pid} $@
    else
        kitten @ $@
    fi
}

function kitten-theme() {
    local theme=$1
    local kitty_themes="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/themes"
    local themes_dir="${XDG_CACHE_HOME:-$HOME/.cache}/themes"
    if [[ ! $theme ]]; then
        local _cmd
        if [[ -d ${themes_dir} ]]; then
            if (($+commands[fd])); then
                _cmd="fd kitty.conf  ${themes_dir}; "
            else
                _cmd="find ${themes_dir} -name 'kitty.conf'"
            fi
        fi
        if [[ -d ${kitty_themes} ]]; then
            if (($+commands[fd])); then
                _cmd="$_cmd fd . ${kitty_themes} -e conf ;"
            else
                _cmd="$_cmd find ${kitty_themes} -name '*.conf' ;"
            fi
        fi
        theme=$(eval "{$_cmd}" | fzf)
    elif [[ $theme != /* ]]; then
        if [[ $theme == */* ]]; then
            if [[ -f "$kitty_themes/$theme/kitty.conf" ]]; then
                theme="$kitty_themes/$theme/kitty.conf"
            fi
        elif [[ -f "${kitty_themes}/${theme}.conf" ]]; then
            theme="${kitty_themes}/${theme}.conf"
        fi
    fi
    [[ -z $theme ]] || kittenr set-colors --all --configured ${theme}
}
