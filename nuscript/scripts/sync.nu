#!/usr/bin/env nu

# Resolve the dotfiles root directory using the configured fallback order.
#
# Parameters:
# - None.
#
# Returns:
# - The selected dotfiles root path.
#
# Exceptions:
# - Raises an error if no candidate directory exists, or no existing candidate is readable and writable.
def resolve-dotfiles-root [] {
  let candidates = [
    ($env.DOTFILES? | default null)
    "~/.config/dotfiles"
    "~/.dotfiles"
    "/etc/dotfiles"
  ]
  | where {|item| $item != null }
  | each {|item| $item | path expand }

  mut checked = []

  for candidate in $candidates {
    if not ($candidate | path exists) {
      $checked = ($checked | append { path: $candidate, exists: false, readable: false, writable: false })
      continue
    }

    let readable = (try {
      ls $candidate | ignore
      true
    } catch {
      false
    })

    let probe = ($candidate | path join $'.m-sync-probe-($env.USER? | default "user")')
    let writable = (try {
      mkdir $probe
      rm -r -f $probe
      true
    } catch {
      false
    })

    $checked = ($checked | append {
      path: $candidate,
      exists: true,
      readable: $readable,
      writable: $writable
    })
  }

  let selected = ($checked | where {|item| $item.exists and $item.readable and $item.writable } | get -o 0.path)
  if ($selected | is-not-empty) {
    return $selected
  }

  let denied = ($checked | where {|item| $item.exists and ((not $item.readable) or (not $item.writable)) } | get path)
  if ($denied | is-not-empty) {
    error make {
      msg: $'no readable/writable dotfiles directory found; checked existing directories: ($denied | str join ", ")'
    }
  }

  error make {
    msg: $'no dotfiles directory found; checked: ($candidates | str join ", ")'
  }
}

# Ensure the destination nuscript directory exists and is readable and writable.
#
# Parameters:
# - target: Destination nuscript directory.
#
# Returns:
# - The validated target path.
#
# Exceptions:
# - Raises an error if the directory cannot be read or written.
def ensure-target [target: string] {
  mkdir $target

  let readable = (try {
    ls $target | ignore
    true
  } catch {
    false
  })

  let probe = ($target | path join $'.m-sync-probe-($env.USER? | default "user")')
  let writable = (try {
    mkdir $probe
    rm -r -f $probe
    true
  } catch {
    false
  })

  if (not $readable or not $writable) {
    error make { msg: $'target directory is not readable/writable: ($target)' }
  }

  $target
}

# Return tracked Nushell files that should be synced.
#
# Parameters:
# - None.
#
# Returns:
# - A list of git-tracked .nu file paths, excluding tests/.
#
# Exceptions:
# - Raises an error if no matching tracked files are found.
def get-tracked-nu-files [] {
  let tracked = (^git ls-files -- '*.nu' ':(exclude)tests/**'
    | lines
    | where {|line| $line | is-not-empty })

  if ($tracked | is-empty) {
    error make { msg: 'no tracked Nushell files found to sync' }
  }

  $tracked
}

# Remove previously synced Nushell files from the destination.
#
# Parameters:
# - target: Destination nuscript directory.
#
# Returns:
# - Nothing.
def clear-existing-nu-files [target: string] {
  let files = (glob ($target | path join '**/*.nu'))
  if ($files | is-not-empty) {
    rm -f ...$files
  }

  let tests_dir = ($target | path join 'tests')
  if ($tests_dir | path exists) {
    rm -r -f $tests_dir
  }
}

# Copy tracked Nushell files into the destination while preserving relative paths.
#
# Parameters:
# - target: Destination nuscript directory.
# - tracked: List of relative source file paths.
#
# Returns:
# - Nothing.
def copy-tracked-files [target: string, tracked: list<string>] {
  for relative in $tracked {
    let source = ($env.PWD | path join $relative)
    let destination = ($target | path join $relative)
    mkdir ($destination | path dirname)
    cp -f $source $destination
  }
}

# Sync tracked Nushell scripts into the selected dotfiles nuscript directory.
#
# Parameters:
# - None.
#
# Returns:
# - Prints the destination path and synced file count.
export def main [] {
  let dotfiles_root = (resolve-dotfiles-root)
  let target = (ensure-target ($dotfiles_root | path join 'nuscript'))
  let tracked = (get-tracked-nu-files)

  clear-existing-nu-files $target
  copy-tracked-files $target $tracked

  print $'synced ($tracked | length) tracked Nushell files to ($target)'
}
