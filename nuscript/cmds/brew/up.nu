use std log
use utils.nu [assert-brew]

# brew update casks
def brew-casks-update [] {
  let casks_tap = "buo/cask-upgrade"
  if ($casks_tap in (^brew tap | lines)) {
    ^brew cu --all --cleanup --yes
  } else {
    log warning $"If you want to be able to pin a certain cask use the tap of '($casks_tap)'"
    ^brew update
    ^brew upgrade --cask
    ^brew cleanup
  }
}

# brew update cli
def brew-cli-update [] {
  log debug "use brew update command."
  ^brew update
  ^brew upgrade
}

# update brew formulae and casks
export def main [] {
  assert-brew
  brew-cli-update
  brew-casks-update
}
