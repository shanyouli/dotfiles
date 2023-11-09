## General

# 以下字符视为单词的一部分
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

# HISTORY 相关配置
## History
HISTFILE="${ZSH_CACHE:=~cache/zsh}/zhistory"
HISTSIZE=100000          # 交互中保存的历史记录
SAVEHIST=$HISTSIZE       # 退出zsh后保存的历史记录大小
# 多个 zsh 间分享历史纪录
setopt SHARE_HISTORY
# 如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
# 为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY
# 在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE


# 修改 esc 超时时间为 0.1s
export KEYTIMEOUT=10

unsetopt BRACE_CCL        # Allow brace character class list expansion.
setopt COMBINING_CHARS    # Combine zero-length punc chars (accents) with base char
setopt RC_QUOTES          # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'
setopt HASH_LIST_ALL

unsetopt CORRECT_ALL
unsetopt NOMATCH
unsetopt MAIL_WARNING     # Don't print a warning message if a mail file has been accessed.
unsetopt BEEP             # Hush now, quiet now.
setopt IGNOREEOF

## Jobs
setopt LONG_LIST_JOBS     # List jobs in the long format by default.
setopt AUTO_RESUME        # Attempt to resume existing job before creating a new process.
setopt NOTIFY             # Report status of background jobs immediately.
unsetopt BG_NICE          # Don't run all background jobs at a lower priority.
unsetopt HUP              # Don't kill jobs on shell exit.
unsetopt CHECK_JOBS       # Don't report on jobs when shell exit.


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

## Directories
DIRSTACKSIZE=9

# 启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD
# 相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS
# 自动改变路径，不需要使用cd
setopt AUTO_CD
# 使用pushd和popd时，不打印切换后目录
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt MULTIOS              # Write to multiple descriptors.

# 加强版通配符
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt GLOB_DOTS
unsetopt AUTO_NAME_DIRS     # Don't add variable-stored paths to ~ list
#

# 在历史记录文件中不写入某些命令
zshaddhistory() {
  case ${1%% *} in
    # ls. la. rm 等命令不会被记录
    (ls|la|rm) return 2 ;;
  esac
  return 0;
}
