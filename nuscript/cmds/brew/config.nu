#!/usr/bin/env nu
use std/log
use utils.nu [assert-brew]

# Show Homebrew and system configuration info useful for debugging.
export def main [
  key?: string # The key to show. All keys if omitted.
] {
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
