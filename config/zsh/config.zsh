## General

# 以下字符视为单词的一部分
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

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
