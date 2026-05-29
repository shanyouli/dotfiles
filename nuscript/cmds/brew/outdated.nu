use utils.nu [assert-brew]

# List installed casks and formulae that have on updated version available.
# Usage: brew outdated
export def main [] {
  assert-brew
  let res = ^brew outdated --json --greedy | from json
  let casks = $res.casks | insert pinned_version null | insert type 'cask'
  let formulae = $res.formulae | insert type 'formula' | reject pinned
  let out = $casks | append $formulae | rename name installed current pinned | sort
  return $out
}
