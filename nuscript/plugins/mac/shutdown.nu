use utils.nu [assert-macos run-applescript]

# shutdown macos
export def main [
  --force(-f), # Force shutdown
  --debug(-d), # show log
  --dry-run, # Do not execute; show what would run
]: nothing -> string {
  assert-macos
  let cmd = if $force {
    'tell app "System Events" to shut down'
  } else {
    'tell app "loginwindow" to «event aevtrsdn»'
  }
  run-applescript $cmd $debug $dry_run
}
