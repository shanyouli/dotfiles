#!/usr/bin/env nu
use std log
use utils.nu [assert-brew]

# Show Homebrew and system configuration info useful for debugging.
# Usage: brew config [key]
# Options:
#    key: The key to show. If not specified, all keys will be shown.
export def main [key?: string] {
  assert-brew
  let conf = ^brew config | lines | parse "{key}: {value}"
  if ($key != null) {
    try {
      return ($conf | where key =~ $key | get value)
    } catch { |err|
      log error $"Key `($key)` does not exist."
    }
  } else {
    return $conf
  }
}
