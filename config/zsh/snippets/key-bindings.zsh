# The surround module wasn't working if KEYTIMEOUT was <= 10. Specifically,
# (delete|change)-surround immediately abort into insert mode if KEYTIMEOUT <=
# 8. If <= 10, then add-surround does the same. At 11, all these issues vanish.
# Very strange!
export KEYTIMEOUT=15

autoload -U is-at-least

# make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )) {
    function zle-line-init() {
        echoti smkx
    }
    function zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
}

## vi-mode ###############
bindkey -v
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins ' ' magic-space
# bindkey -M viins '^I' expand-or-complete-prefix

# surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround

# <5.0.8 doesn't have visual map
if is-at-least 5.0.8; then
  bindkey -M visual 'S' add-surround
  # add vimmish text-object support to zsh
  autoload -U select-quoted; zle -N select-quoted
  for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
      bindkey -M $m $c select-quoted
    done
  done
  autoload -U select-bracketed; zle -N select-bracketed
  for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
      bindkey -M $m $c select-bracketed
    done
  done
fi

# Open current prompt in external editor
autoload -Uz edit-command-line; zle -N edit-command-line
bindkey '^ ' edit-command-line
# 在命令前插入 sudo
# https://github.com/goreliu/zshguide/wiki/.zshrc
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    # 光标移动到行末
    zle end-of-line
}

zle -N sudo-command-line
bindkey '^y' sudo-command-line

bindkey -M viins '^s' history-incremental-pattern-search-backward
bindkey -M viins '^u' backward-kill-line
bindkey -M viins '^w' backward-kill-word
bindkey -M viins '^b' backward-word
bindkey -M viins '^f' forward-word
bindkey -M viins '^g' push-line-or-edit
bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^e' end-of-line
# bindkey -M viins '^d' push-line-or-edit

bindkey -M vicmd '^k' kill-line
bindkey -M vicmd 'H'  run-help

# Shift + Tab
bindkey -M viins '^[[Z' reverse-menu-complete


# C-z to toggle current process (background/foreground)
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Completing words in buffer in tmux
if [ -n "$TMUX" ]; then
  _tmux_pane_words() {
    local expl
    local -a w
    if [[ -z "$TMUX_PANE" ]]; then
      _message "not running inside tmux!"
      return 1
    fi
    w=( ${(u)=$(tmux capture-pane \; show-buffer \; delete-buffer)} )
    _wanted values expl 'words from current tmux pane' compadd -a w
  }

  zle -C tmux-pane-words-prefix   complete-word _generic
  zle -C tmux-pane-words-anywhere complete-word _generic

  bindkey -M viins '^x^n' tmux-pane-words-prefix
  bindkey -M viins '^x^o' tmux-pane-words-anywhere

  zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' completer _tmux_pane_words
  zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' ignore-line current
  zstyle ':completion:tmux-pane-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'
fi

# Vim's C-x C-l in zsh
history-beginning-search-backward-then-append() {
  zle history-beginning-search-backward
  zle vi-add-eol
}
zle -N history-beginning-search-backward-then-append
bindkey -M viins '^x^l' history-beginning-search-backward-then-append

# Fix the DEL key
bindkey -M vicmd "^[[3~" delete-char
bindkey "^[[3~" delete-char

# Fix vimmish ESC
bindkey -sM vicmd '^[' '^G'
bindkey -rM viins '^X'
bindkey -M viins '^X,' _history-complete-newer \
  '^X/' _history-complete-older \
  '^X`' _bash_complete-word

# M-x # 棒棒 M-x
function execute-command() {
    local selected=$(printf "%s\n" ${(k)widgets} | ftb-tmux-popup --reverse --prompt="cmd> " --height=10 )
    zle redisplay
    [[ $selected ]] && zle $selected
}
zle -N execute-command
bindkey '^[x' execute-command

# zce 相关函数，快速跳转, 需要配置 https://github.com/hchbaw/zce.zsh
function zce-jump-char() {
    [[ -z $BUFFER ]] && zle up-history
    zstyle ':zce:*' keys 'asdghklqwertyuiopzxcvbnmfj;23456789'
    zstyle ':zce:*' prompt-char '%B%F{green}Jump to character:%F%b '
    zstyle ':zce:*' prompt-key '%B%F{green}Target key:%F%b '
    with-zce zce-raw zce-searchin-read
    CURSOR+=1
}
zle -N zce-jump-char
bindkey -a '^[j' zce-jump-char

# 删除到指定字符
function zce-delete-to-char() {
    [[ -z $BUFFER ]] && zle up-history
    local pbuffer=$BUFFER pcursor=$CURSOR
    local keys=${(j..)$(print {a..z} {A..Z})}
    zstyle ':zce:*' prompt-char '%B%F{yellow}Delete to character:%F%b '
    zstyle ':zce:*' prompt-key '%B%F{yellow}Target key:%F%b '
    zce-raw zce-searchin-read $keys

    if (( $CURSOR < $pcursor ))  {
        pbuffer[$CURSOR,$pcursor]=$pbuffer[$CURSOR]
    } else {
        pbuffer[$pcursor,$CURSOR]=$pbuffer[$pcursor]
        CURSOR=$pcursor
    }
    BUFFER=$pbuffer
}
zle -N zce-delete-to-char
bindkey -a '^Xj' zce-delete-to-char
