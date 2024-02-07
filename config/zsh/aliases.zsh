alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias home='cd ~'

# alias q=exit
alias clr=clear
# alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

alias mk=make
# alias rcp='rsync -vaP --delete'
alias rmirror='rsync -rtvu --delete'
alias gurl='curl --compressed'


if [[ $(uname) == "Linux" ]]; then
  alias sc=systemctl
  alias ssc='sudo systemctl'
  alias usc='systemctl --user'

  alias y='xclip -selection clipboard -in'
  alias p='xclip -selection clipboard -out'
fi

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

if (( $+commands[eza] )) then
   alias l="eza --git --group-directories-first --time-style=long-iso"
   alias ls='l -lbF' # list, size, type
   alias lsi='l --icons'
   alias ll='ls -la' # long, all
   alias llm='ll --sort=modified' # list, long, sort by modification date
   alias la='ls -lbhHigUmuSa' # all list
   alias lx='ls -lbhHigUmuSa@' # all list and extended
   alias tree="eza --tree -I '.git'"
   alias treei="tree --icons"
   alias lS='eza -1' # one column by just names
fi


# 在sudo中使用用户环境变量
alias mysudo='sudo -E env "PATH=$PATH"'


# Proxy
function setproxy() {
  local url=http://127.0.0.1:${1:-10801}
  export http_proxy=$url
  export https_proxy=$url
  export all_proxy=$url
  export no_proxy=10.*.*.*,192.168.*.*,*.local,localhost,127.0.0.1
  echo "proxy=$url"
}
function unsetproxy() { unset http_proxy https_proxy all_proxy no_proxy ; }

# 通过 alias -g xxxx=yyy 设置，在指令的任何地方遇到单独的 xxx 都会被替换为 yyy
alias -g :n='/dev/null'

# txt文件使用nvim工具打开
alias -s txt='nvim'

# fd
alias fda="fd -IH"
