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

alias mk=make
alias rcp='rsync -vaP --delete'
alias rmirror='rsync -rtvu --delete'
alias gurl='curl --compressed'

alias y='xclip -selection clipboard -in'
alias p='xclip -selection clipboard -out'

alias sc=systemctl
alias ssc='sudo systemctl'
alias usc='systemctl --user'
if [[ -n ${commands[exa]} ]]; then
  alias exa="exa --group-directories-first";
  alias ls="exa"
  alias l="exa -1";
  alias ll="exa -lg";
  alias la="LC_COLLATE=C exa -la";
fi

autoload -U zmv

take() {
  mkdir "$1" && cd "$1";
}; compdef take=mkdir

zman() {
  PAGER="less -g -s '+/^       "$1"'" man zshall;
}
function man() {
  env \
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

r() {
  local time=$1; shift
  sched "$time" "notify-send --urgency=critical 'Reminder' '$@'; ding";
}; compdef r=sched
