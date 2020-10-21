alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

alias q=exit
alias clr=clear
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias wget='wget -c'

alias mk=make
alias rcp='rsync -vaP --delete'
alias rmirror='rsync -rtvu --delete'
alias gurl='curl --compressed'

alias y='xclip -selection clipboard -in'
alias p='xclip -selection clipboard -out'

autoload -U zmv

take() {
  mkdir "$1" && cd "$1";
}; compdef take=mkdir

zman() {
  PAGER="less -g -s '+/^       "$1"'" man zshall;
}

r() {
  local time=$1; shift
  sched "$time" "notify-send --urgency=critical 'Reminder' '$@'; ding";
}; compdef r=sched

unproxy() {  unset https_proxy http_proxy all_proxy rsync_proxy ftp_proxy ; }
sproxy() {
  local _proxy=http://127.0.0.1:${1:-7890}
  export http_proxy=${_proxy}
  export https_proxy=${_proxy}
  export all_proxy=${_proxy}
  export ftp_proxy=${_proxy}
  export rsync_proxy=${_proxy}
}
