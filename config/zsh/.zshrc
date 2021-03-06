source $ZDOTDIR/config.zsh

typeset -gA ZINIT=(
  HOME_DIR        $XDG_DATA_HOME/zinit
  ZCOMPDUMP_PATH  $ZSH_CACHE
  COMPINIT_OPTS   -C
)

# Common ICE modifiers
function zt { zinit depth"1" lucid  ${1/#[0-9][a-c]/wait"$1"} "${@:2}" ; }
function zice {
  local _all=( $@ )
  local _wait
  local _package
  if [[ ${_all[1]} == [0-9][a-c] ]]; then
    _wait=wait"${_all[1]}"
    shift _all
  fi
  _package=${_all[-1]}
  zinit ice lucid depth'1' $_wait ${_all:0:-1}
  zinit load $_package
}
# declare -x -A ZINIT=(
#   [HOME_DIR]="$XDG_CACHE_HOME/zinit"
#   [BIN_DIR]="$XDG_CACHE_HOME/zinit/bin"
# )

[[ -f "$ZDOTDIR/prev.zshrc" ]] && source "$ZDOTDIR/prev.zshrc"

if [[ -z ${ZINIT[BIN_DIR]} ]] ; then
  export ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/bin"
  [[ -d "${ZINIT[BIN_DIR]}" ]] || {
    git clone --depth 1 https://github.com/zdharma/zinit "${ZINIT[BIN_DIR]}"
  }
  source "${ZINIT[BIN_DIR]}/zinit.zsh"
fi

zt 0a light-mode for \
    blockf \
        zsh-users/zsh-completions \
    compile'{src/*.zsh,src/strategies/*}' pick'zsh-autosuggestions.zsh' \
    atload'_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions

zt 0b light-mode for \
    compile'{hsmw-*,test/*}' \
        zdharma/history-search-multi-word \
    pick'autopair.zsh' nocompletions atload'bindkey "^H" backward-kill-word;
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
        hlissner/zsh-autopair \
        zsh-users/zsh-history-substring-search

# history-search-multi-word config
# # Color in which to highlight matched, searched text
# (default bg=17 on 256-color terminals)
zstyle ":history-search-multi-word" highlight-color "fg=yellow,bold"
# Whether to perform syntax highlighting (default true)
zstyle ":plugin:history-search-multi-word" synhl "yes"
# Effect on active history entry. Try: standout, bold, bg=blue (default underline)
zstyle ":plugin:history-search-multi-word" active "underline"
# Whether to check paths for existence and mark with magenta (default true)
zstyle ":plugin:history-search-multi-word" check-paths "yes"
 # Whether pressing Ctrl-C or ESC should clear entered query
zstyle ":plugin:history-search-multi-word" clear-on-cancel "no"
# fast-syntax-highlighting
zice 0b if'[[ -z $SSH_CONNECTION ]]' zdharma/fast-syntax-highlighting

# fast alias-tips
zice 0a from'gh-r' as'program' sei40kr/fast-alias-tips-bin
zice 0c sei40kr/zsh-fast-alias-tips

# 快速目录跳转
if [[ -z ${commands[z]} ]]; then
  zice 0c agkozak/zsh-z
  export ZSHZ_DATA=$ZSH_CACHE/zlua
fi
# fzf fzf-tmux
if [[ -z ${commands[fzf-share]} ]]; then
  zice 0a from"gh-r" as"program" junegunn/fzf-bin
  # zinit ice mv="*.zsh -> _fzf" as="completion"
  zinit snippet 'https://github.com/junegunn/fzf/blob/master/shell/completion.zsh'
  zinit snippet 'https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh'
fi

zice 3c pick"fz.sh" changyuheng/fz
# use wd mark fold
export WD_CONFIG=$ZSH_CACHE/warprc
zice 0c blockf as"program" pick"wd.sh" mv"_wd.sh -> _wd" atload="wd() { source wd.sh }" mfaerevaag/wd
[[ -d "${ZINIT[COMPLETIONS_DIR]}" ]] || mkdir -p ${ZINIT[COMPLETIONS_DIR]}
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit
zinit add-fpath "$ZDOTDIR/completions"

autoload -Uz compinit && compinit -u -d $ZSH_CACHE/cache/zcompdump

if [[ $TERM != dumb ]]; then
  source $ZDOTDIR/keybinds.zsh
  source $ZDOTDIR/completion.zsh
  source $ZDOTDIR/aliases.zsh
  source $ZDOTDIR/color.zsh
  # fd > find
  if command -v fd >/dev/null; then
    export FZF_DEFAULT_OPTS="--reverse --ansi"
    export FZF_DEFAULT_COMMAND="fd ."
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd -t d . $HOME"
  fi

  ## Auto-generated by my nix config
  source $ZDOTDIR/extra.zshrc

  # If you have host-local configuration, this is where you'd put it
  if [[ -f ~/.zshrc ]]; then source ~/.zshrc ; fi
fi
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0222222" #black
    echo -en "\e]P8222222" #darkgrey
    echo -en "\e]P1803232" #darkred
    echo -en "\e]P9982b2b" #red
    echo -en "\e]P25b762f" #darkgreen
    echo -en "\e]PA89b83f" #green
    echo -en "\e]P3aa9943" #brown
    echo -en "\e]PBefef60" #yellow
    echo -en "\e]P4324c80" #darkblue
    echo -en "\e]PC2b4f98" #blue
    echo -en "\e]P5706c9a" #darkmagenta
    echo -en "\e]PD826ab1" #magenta
    echo -en "\e]P692b19e" #darkcyan
    echo -en "\e]PEa1cdcd" #cyan
    echo -en "\e]P7ffffff" #lightgrey
    echo -en "\e]PFdedede" #white
    clear #for background artifacting
fi
