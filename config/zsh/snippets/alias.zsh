# global alias
# 通过 alias -g xxxx=yyy 设置，在指令的任何地方遇到单独的 xxx 都会被替换为 yyy
alias -g H='| head ' T='| tail ' L='| less ' R='| rgc '
# alias -g S='| sort ' U='| uniq '
alias -g N='>/dev/null '
# https://roylez.info/2010-03-06-zsh-recent-file-alias/
alias -g NN="*(oc[1])" NNF="*(oc[1].)" NND="*(oc[1]/)"

# cd 相关
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias home='cd ~'

# 清屏
alias clr=clear


# 在sudo中使用用户环境变量
alias mysudo='sudo -E env "PATH=$PATH"'

# proxy 配置
function isInt() {
    local re='^[0-9]+$'
    [[ $1 =~ $re ]]
}

function proxy() {
    local url=http://127.0.0.1:${1:-10801}
    export http_proxy=$url
    export https_proxy=$url
    export all_proxy=$url
    export HTTP_PROXY=$url
    export HTTPS_PROXY=$url
    export ALL_PROXY=$url
    export no_proxy=10.*.*.*,192.168.*.*,*.local,localhost,127.0.0.1
    export NO_PROXY=10.*.*.*,192.168.*.*,*.local,localhost,127.0.0.1
    echo "proxy=$url"
}

function unproxy() {
    unset http_proxy https_proxy all_proxy no_proxy  \
      HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
}

function pp() {
    local port=10801
    if isInt $1; then
        port=$1
        shift
    fi
    local url=http://127.0.0.1:$port
    env http_proxy="$url" \
        httpS_proxy="$url" \
        HTTP_PROXY="$url" \
        HTTPS_PROXY="$url"  "$@"
}
