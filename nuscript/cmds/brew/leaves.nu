use utils.nu [assert-brew]

# List formulae not required as dependencies of any installed formula or cask.
export def main [] {
  assert-brew
  let on_request = ^brew leaves --installed-on-request
                   | lines
                   | parse "{name}"
                   | insert "type" "on request"
  let as_dependency = ^brew leaves --installed-as-dependency
                      | lines
                      | parse "{name}"
                      | insert "type" "as dependency"
  $on_request | merge ($as_dependency) | sort
}
