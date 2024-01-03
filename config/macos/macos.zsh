#!/usr/bin/env zsh

function random_el_in_arr() {
    local arr=("$@")
    printf '%s' "${arr[RANDOM % $#]}"
}

function _setDNS() {
    local IFS=$'\n'
    for i in $(networksetup -listallnetworkservices | tail -n +2); do
        networksetup -setdnsservers "$i" "$@"
    done
}

function clear_dns() { _setDNS 'Empty'; }

function set_dns() {
  # 使用 阿里云，百度云，114DNS，CNNIC DNS， 腾讯
    local all_dns=("223.5.5.5" "223.6.6.6" \
        "114.114.114.114" "114.114.115.115" \
        "1.2.4.8" "210.2.4.8" \
        "119.29.29.29" "119.28.28.28" \
        "101.226.4.6" "180.184.1.1")
    local dns1=$(random_el_in_arr "${all_dns[@]}")
    local dns2=$(random_el_in_arr "${all_dns[@]}")
    _setDNS "$dns1" "$dns2"
}

# 清理dns缓存
alias clearDNS="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

function getAliasPath() {
    osascript -e "
      tell application \"Finder\"
        set theItem to (POSIX file \"$1\") as alias
        if the kind of theItem is \"alias\" then
          get the POSIX path of ((original item of theItem) as text)
        end if
      end tell
    "
}

function setAliasPath() {
    osascript -e "
      set originalPath to \"$1\"
      set aliasPath to \"$2\"

      tell application \"Finder\"
        set originalFile to POSIX file originalPath as alias
        make new alias file at folder (POSIX file aliasPath as alias) to originalFile
      end tell
    "
}

function clearAppsAlias() {
    for i in $HOME/Applications/Myapps/*; do
        aliasPath=$(getAliasPath $i)
        if [[ ! -e ${aliasPath} ]]; then
            rm -rf $i
        fi
    done
}

function sc() {
    local server_name=""
    if [[ "${2}" == *"."* ]]; then
        server_name="$2"
    else
        server_name="org.nixos."$2
    fi
    case $1 in
        start) launchctl start $server_name;;
        stop) launchctl stop $server_name;;
        restart) launchctl stop $server_name
                 sleep 0.3
                 launchctl start $server_name;;
        status) launchctl list $server_name;;
        *) launchctl $@;;
    esac
}


function restart-sc() {
    for i in $(launchctl list | grep -i nix | awk '($1 == "-" && $2 != "0") {print $3}'); do
        launchctl start $i
    done
}


function cleards() {
    local _dirname=${1:-$HOME}
    if (( $+commands[fd] )); then
        fd '.DS_Store' -I -H --type f $_dirname -x rm -rf {}
        fd '.localized' -I -H --type f $_dirname -x rm -rf {}
    else
        find $_dirname '(' -name '*.DS_Store' -or -name '*.localized' ')' -type f  -exec rm -rf {} \;
    fi
}

# 重置 Launchpad
alias macrd="defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock"

if (( $+commands[brew] )); then
    alias bu='brew update && brew upgrade && brew cleanup'
    alias bcu='brew cu --all --yes --cleanup'
    alias bua='bu ; bcu'
    alias bin='{brew formulae; brew casks; } | fzf | xargs brew install'
    alias bri='brew list | fzf | xargs brew reinstall'
    alias brm='brew list | fzf | xargs brew uininstall'
    alias bcl='brew cleanup'
    function brew-set-mirror() {
        local domain="https://mirrors.bfsu.edu.cn"
        if [[ -n $1 ]] && [[ $1 == "tuna" ]]; then
            domain="https://mirrors.tuna.tsinghua.edu.cn"
        fi
        export HOMEBREW_CORE_GIT_REMOTE="$domain/git/homebrew/homebrew-core.git"
        for tap in core cask{,-versions} command-not-found services; do
            # not cask-fonts,
            brew tap --custom-remote --force-auto-update "homebrew/${tap}" "$domain/git/homebrew/homebrew-${tap}.git"
        done
        brew update
    }
fi

function upclash() {
    local _clash_verge="Clash Nyanpasu.app"
    if [[ -d "/Applications/${_clash_verge}" ]]; then
        _clash_verge="/Applications/${_clash_verge}"
    elif [[ -d "$HOME/Applications/${_clash_verge}" ]]; then
        _clash_verge="$HOME/Applications/${_clash_verge}"
    elif [[ -d $HOME/Applications/Myapps/${_clash_verge} ]]; then
        _clash_verge="$HOME/Applications/Myapps/${_clash_verge}"
    else
        _clash_verge=""
    fi
    [[ $_clash_verge == "" ]] || {
        sudo chown root:admin "$_clash_verge/Contents/MacOS/clash-meta"
        sudo chmod +sx "$_clash_verge/Contents/MacOS/clash-meta"
        sudo chown root:admin "$_clash_verge/Contents/MacOS/clash"
        sudo chmod +sx "$_clash_verge/Contents/MacOS/clash"
    }
}

mmac-reopen() {
    # https://apple.stackexchange.com/questions/129327/avoiding-all-apps-reopening-when-os-x-crashes
    local uuid=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')
    local _file= ${HOME}/Library/Preferences/ByHost/com.apple.loginwindow.${uuid}.plist
    local change=stop
    if [[ -n $1 ]]; then
        change=start
    fi
    sudo /usr/bin/chflags nouchg $_file
    if [[ $change == start ]]; then
        /usr/libexec/PlistBuddy -c 'Delete :TALAppsToRelaunchAtLogin' $_file
        sudo /usr/bin/chflags uimmutable $_file
    fi
}

function poweroff() { sudo /sbin/shutdown -h now ; }
