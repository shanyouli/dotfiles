#!/usr/bin/env zsh
# shellcheck shell-bash

function use-tput() {
    # 是否使用tput进行颜色输出
    if command -v tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
        if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
            return 0
        fi
    fi
    return 1
}

function echo-error {
    # RED , BLoD
    if use-tput; then
        echo -e "$(tput bold)$(tput setaf 1)$1$(tput sgr0)"
    else
        echo -e "\e[1;31m$1\e[0m"
    fi
}

function echo-success {
    # GREEN , BLoD
    if use-tput; then
        echo -e "$(tput bold)$(tput setaf 2)$1$(tput sgr0)"
    else
        echo -e "\e[1;32m$1\e[0m"
    fi
}

function echo-info {
    # GREEN , BLoD
    if use-tput; then
        echo -e "$(tput bold)$(tput setaf 4)$1$(tput sgr0)"
    else
        echo -e "\e[1;34m$1\e[0m"
    fi
}
function echo-warn {
    # GREEN , BLoD
    if use-tput; then
        echo -e "$(tput bold)$(tput setaf 3)$1$(tput sgr0)"
    else
        echo -e "\e[1;33m$1\e[0m"
    fi
}
function is-rsync() {
    if command -v rsync >/dev/null; then
        if [[ $(uname) == "Darwin" ]] && [[ $(which rsync) == "/usr/bin/rsync" ]]; then
            echo-warn "Please update rsync"
            return 1
        fi
    else
        return 1
    fi
}

function rmv() {
    if is-rsync; then
        rsync -ah --progress --no-i-r --remove-source-files "$@" && {
            for i in "$@"; do
                if [[ -d $i ]] && [[ $(find $i -type f | wc -l) -eq 0 ]]; then
                    rm -rf $i
                    continue
                fi
            done
        }
    else
        mv -vf "$@"
    fi
}
compdef rmv=rsync

function rcp() {
    if is-rsync; then
        rsync -ah --progress --no-i-r "$@"
    else
        cp -rv "$@"
    fi
}
compdef rcp=rsync
