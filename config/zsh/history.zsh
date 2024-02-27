# HISTORY 相关配置
## History
export HISTFILE="${ZSH_CACHE:=~cache/zsh}/zhistory"
export HISTSIZE=100000          # 交互中保存的历史记录
export SAVEHIST=$HISTSIZE       # 退出zsh后保存的历史记录大小
# 多个 zsh 间分享历史纪录
setopt SHARE_HISTORY
# 如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
# 为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY
# 在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE

setopt BANG_HIST                 # Don't treat '!' specially during expansion.
setopt APPEND_HISTORY            # Appends history to history file on exit
setopt appendhistory            # Appends history to history file on exit
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing non-existent history.

# 在历史记录文件中不写入某些命令
zshaddhistory() {
  case ${1%% *} in
    # ls. la. rm 等命令不会被记录
    (ls|la|rm) return 2 ;;
  esac
  return 0;
}
