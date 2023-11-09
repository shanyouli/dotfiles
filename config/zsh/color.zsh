# -*- mode: sh -*-
# see@ https://github.com/zpm-zsh/colorize/blob/master/colorize.plugin.zsh
export LESS="$LESS -R -M"

function ip() { command ip --color=auto "$@"; }

function grep() { command grep --colour=auto "$@" ; }
function egrep() { command egrep --colour=auto "$@" ; }
function fgrep() { command fgrep --colour=auto "$@" ; }

if (( $+commands[diff-so-fancy] )); then
    function diff() { command diff "$@" | diff-so-fancy ; }
elif (( $+commands[delta] )); then
    function diff() { command diff "$@" | delta ; }
else
    function diff() { command diff --color "$@" ; }
fi

[[ $(tput colors) -ge 256 ]] && {
    function man() {
        command env \
            LESS_TERMCAP_md=$(tput bold; tput setaf 4) \
            LESS_TERMCAP_me=$(tput sgr0) \
            LESS_TERMCAP_mb=$(tput blink) \
            LESS_TERMCAP_us=$(tput setaf 2) \
            LESS_TERMCAP_ue=$(tput sgr0) \
            LESS_TERMCAP_so=$(tput smso) \
            LESS_TERMCAP_se=$(tput rmso) \
            PAGER="${commands[less]:-$PAGER}" \
        man "$@"
    };
}


(( $+commands[grc] )) && {
    function env() { command grc --colour=auto env "$@" ; }
    function lsblk() { command grc --colour=auto lsblk "$@" ; }
    function df() { command grc --colour=auto df -h "$@" ; }
    function du() { command grc --colour=auto du -h "$@" ; }
    function as() { command grc --colour=auto as "$@" ; }

    (( $+commands[dig] )) && function dig() { command grc --colour=auto dig "$@" ; }

    (( $+commands[gas] )) && function gas() { command grc --colour=auto gas "$@" ; }

    (( $+commands[gcc] )) && function g() ++() { command grc --colour=auto g++ "$@" ; }

    (( $+commands[last] )) && function last() { command grc --colour=auto last "$@" ; }

    (( $+commands[ld] )) && function ld() { command grc --colour=auto ld "$@" ; }

    (( $+commands[ifconfig] )) && function ifconfig() { command grc --colour=auto ifconfig "$@" ; }

    (( $+commands[mount] )) && function mount() { command grc --colour=auto mount "$@"; }

    (( $+commands[mtr] )) && function mtr() { command grc --colour=auto mtr "$@"; }

    (( $+commands[netstat] )) && function netstat() { command grc --colour=auto netstat "$@"; }

    (( $+commands[ping] )) && function ping() { command grc --colour=auto ping "$@";}


    (( $+commands[ping6] )) && function ping6() { command grc --colour=auto ping6 "$@" ; }


    (( $+commands[ps] )) && function ps() { command grc --colour=auto ps "$@"; }


  (( $+commands[traceroute] )) && function traceroute() { command grc --colour=auto traceroute "$@"; }
}
