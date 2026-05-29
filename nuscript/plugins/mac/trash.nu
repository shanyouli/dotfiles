use std log
use utils.nu [assert-macos run-applescript]

# check privilege
def check-trash-privilege [] {
  try {
    ls ($env.HOME | path join ".Trash")
    return true
  } catch {
    log debug "This requires Terminal 'Full Disk Access' permission to work properly."
    return false
  }
}

def trash-clean [
  debug: bool, # show log
  dry_run: bool, # Do not execute; show what would run
] {
  let cmd = 'tell application "Finder" to empty the trash'
  run-applescript  $cmd  $debug $dry_run
}

def trash-status [] {
  let trash_home = $env.HOME | path join ".Trash"
  let trash_size = du $trash_home | get physical | first
  let trash_files = (glob -D $"($trash_home)/**" | length) - 1
  print $"Size: ($trash_size)"
  print $"Number of files: ($trash_files)"
}

# trash command management
export def main [
  --status(-s), # show the status of the trash
  --clean(-c), # Clean the trash
  --debug(-d), # show log
  --dry-run # Do not execute; show what would run
] {
  assert-macos
  if (check-trash-privilege) {
    if $status {
      trash-status
      return
    }
    if $clean {
      trash-clean $debug $dry_run
      return
    }
    print "Please provide a flag: --status or --clean"
  } else {
    error make {
      msg: "This requires Terminal 'Full Disk Access' permission to work properly"
    }
  }
}
