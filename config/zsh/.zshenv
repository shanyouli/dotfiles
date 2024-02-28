#!/usr/bin/env zsh

if [[ -z $DOTFILES ]]; then
    for i in "/etc/dotfiles" "/etc/nixos" "$HOME/.config/dotfiles" "$HOME/.dotfiles" "$HOME/.nixpkgs"; do
        if [ -d $i ] && [[ -d $i/.git ]] && [[ -f $i/flake.nix ]]; then
            export DOTFILES=$i
            break
        fi
    done
fi

: ${XDG_CONFIG_HOME:=~/.config}
: ${XDG_CACHE_HOME:=~/.cache}
: ${XDG_DATA_HOME:=~/.local/share}
: ${ZDOTDIR:=$XDG_CONFIG_HOME/zsh}

# source file, When file exits
function _source {
    local file
    for file in "$@"; do
        if [[ -r $file ]]; then
            source $file
        fi
    done
}

function _dsource {
    local file="$1"
    if ! [[ -r "$file" ]]; then
        if [[ -n "$DOTFILES" ]] && [[ -r "$DOTFILES/config/$file" ]]; then
            file="$DOTFILES/config/$file"
        elif [[ -n $ZDOTDIR ]] && [[ -r "$ZDOTDIR/$file" ]]; then
            file="$DOTFILES/$file"
        else
            echo "Warning: not found file $file"
            return 0
        fi
    fi
    source "$file"
}

# command -v "$1" >/dev/null || return 1
function _cache {
    if (( $+commands[$1] )) || [[ -x $1 ]]; then
        local cache_dir="$XDG_CACHE_HOME/${SHELL##*/}/cache"
        local cache="$cache_dir/${1##*/}"
        if [[ ! -f $cache || ! -s $cache ]]; then
            echo "Caching $1"
            mkdir -p $cache_dir
            "$@" >$cache
            chmod 600 $cache
        fi

        if [[ -o interactive ]]; then
            source $cache || rm -f $cache
        fi
    else
        return 1
    fi
}

export LANGUAGE=en_US # :zh_CN

# export GTAGSLABEL=pygments

# 用 typeset -U path 给它设置 unique 属性，使得 $PATH 自动去重
typeset -U path
path=( $path )

typeset -U fpath
fpath=(  $fpath )

export XDG_DATA_HOME
export XDG_CONFIG_HOME
export XDG_CACHE_HOME
export ZDOTDIR

_source "$ZDOTDIR/cache/extra.zshenv" "~/.zshenv"
