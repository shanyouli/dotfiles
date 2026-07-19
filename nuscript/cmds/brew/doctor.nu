use std/log
use utils.nu [assert-brew]
# Check your system for potential problems.
# Usage: brew doctor
export def main [] {
  assert-brew
  let output = ^brew doctor o+e>| complete
  if ($output.exit_code != 0) {
    log warning $"exit_code: ($output.exit_code)"
  }
  if ($output.stdout | is-empty) {
    log debug "No diagnostic information."
    exit $output.exit_code
  }
  $output.stdout | split row -r '\n\n' | skip 1 | parse "{status}: {message}"
}
