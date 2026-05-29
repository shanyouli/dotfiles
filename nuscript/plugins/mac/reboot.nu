use utils.nu [assert-macos run-applescript]

# reboot macos
export def main [
  --force(-f), # Force reboot
  --debug(-d), # show log
  --dry-run, # Do not execute; show what would run
]: nothing -> string {
  assert-macos
  let cmd = if $force {
    'tell app "System Events" to restart'
  } else {
    'tell app "loginwindow" to «event aevtrrst»'
  }
  run-applescript $cmd $debug $dry_run
}
