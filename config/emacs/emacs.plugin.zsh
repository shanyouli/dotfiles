#!/usr/bin/env zsh

function doom() {
    # 不导入某些变量
    unset FZF_DEFAULT_OPTS
    if [[ -n $EMACSDIR ]]; then
        _DOOM_HOME=$EMACSDIR
    elif [[ -d ${XDG_CONFIG:-${HOME}/.config}/emacs ]]; then
        _DOOM_HOME=${XDG_CONFIG:-${HOME}/.config}/emacs
    else
        _DOOM_HOME=${HOME}/.emacs.d
    fi
    if [[ -n $1 ]]; then
        _setenv=0
        if [[ $1 == "env" ]]; then
            _setenv=1
        elif [[ $1 == "upgrade" ]] || [[ $1 == "install" ]]; then
            _setenv=2
        elif [[ $1 == "sync" ]]; then
            shift
            ${_DOOM_HOME}/bin/doom sync -e "$@"
            return 0
        fi
        ${_DOOM_HOME}/bin/doom "$@"

        [[ $_setenv -ge 1 ]] && {
            /usr/bin/sed -i".bak" 's?"EMACSLOADPATH="??g' "$_DOOM_HOME/.local/env"
            /usr/bin/sed -i".bak" 's?"EMACSNATIVELOADPATH="??g' "$_DOOM_HOME/.local/env"
            /usr/bin/sed -i".bak" '/^[ ]*$/d' "$_DOOM_HOME/.local/env"
            [[ -f $_DOOM_HOME/.local/env.bak ]] && rm -rf $_DOOM_HOME/.local/env.bak
            [[ $_setenv -eq 2 ]] && $_DOOM_HOME/bin/doom sync -e
        }
    else
        ${_DOOM_HOME}/bin/doom "$@"
    fi
}

# clear scrollback
if [ -n $INSIDE_EMACS ]; then
    ISABLE_AUTO_TITLE="true"
    if [[ "$INSIDE_EMACS" == 'vterm' ]]; then

        _source $EMACS_VTERM_PATH/etc/emacs-vterm-zsh.sh

        vterm_printf() {
            if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]); then
                # Tell tmux to pass the escape sequences through
                printf "\ePtmux;\e\e]%s\007\e\\" "$1"
            elif [ "${TERM%%-*}" = "screen" ]; then
                # GNU screen (screen, screen-256color, screen-256color-bce)
                printf "\eP\e]%s\007\e\\" "$1"
            else
                printf "\e]%s\e\\" "$1"
            fi
        }

        function vterm_prompt_end() {
            vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
        }

        setopt PROMPT_SUBST
        PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

        alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
        alias reset='vterm_printf "51;Evterm-clear-scrollback";tput clear'

        # 本地机器
        vterm_set_directory() {
            functions vterm_cmd >/dev/null && vterm_cmd update-pwd "$PWD/"
        }
        autoload -U add-zsh-hook
        add-zsh-hook -Uz chpwd (){ vterm_set_directory }
        # if (( $+commands[fzf] )) ; then
        #     bindkey -M viins '^r' fzf-history-widget
        # fi
    fi
fi

function emacsclient() {
    local name="emacs"
    if [[ $(uname) == Darwin ]]; then
        name="Emacs"
    fi
    local sock_file=$(lsof -c $name | grep main | tr -s " " | cut -d' ' -f8)
    if [[ $sock_file == "" ]]; then
        sock_file=$(lsof -c $name | grep server | tr -s " " | cut -d' ' -f8)
    fi
    local _arg=""
    if [[ $sock_file != "" ]]; then
        command emacsclient -s $sock_file $@
    else
        command emacsclient $@
    fi
}

alias ec=emacsclient
alias ecn="emacsclient -nw -n"
alias ecc="emacsclient -n -c"
