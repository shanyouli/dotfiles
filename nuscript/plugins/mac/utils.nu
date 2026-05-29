use std log

# ----------------------------------------
# System check: Ensure running on macOS
# ----------------------------------------
export def assert-macos [] {
    let sys = (sys host | get name)
    if $sys != "macos" and $sys != "Darwin" {
      error make {
        msg: $"This command only works on macOS. Detected: ($sys)",
      }
    }
}

# Helper: run or preview an AppleScript cmd
export def run-applescript [
  cmd: string,
  debug: bool,
  dry_run: bool,
] {
  if $dry_run {
    log info $"[dry-run] Would execute AppleScript : ($cmd)"
    return $"osascript -e '($cmd)'"
  }
  if $debug {
    log info $"Executing AppleScript: ($cmd)"
  }
  try {
    ^osascript -e $cmd | str trim
  } catch {
    let err = (error-message)
    log error $"AppleScript failed: ($err)"
    error make {
      msg: $"Failed to run: osascript -e '($cmd)'"
    }
  }
}
