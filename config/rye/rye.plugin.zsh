#!/usr/bin/env zsh
#
function rye {
    local _python

    # 检查是否需要处理 --python 参数
    if [[ $* == *"--python"* ]]; then
        command rye "$@"
        return 0
    fi

    # 获取默认的 Python toolchain
    _python=$(command rye config --get default.toolchain)

    # 如果匹配了 tools install 或 install，并且有合理的默认 Python 版本，添加 --python 参数
    if [[ $# -gt 2 && ($1 == "tools" && $2 == "install" || $1 == "install") ]] && [[ $_python =~ @[0-9.]+ ]]; then
        command rye "$@" --python "${_python}"
    else
        if [[ ${_python} == "?" ]]; then
            echo "Warn: not found default.toolchain. Will use default Python."
        fi
        command rye "$@"
    fi
}

alias pipx='rye tools'
