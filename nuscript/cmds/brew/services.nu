use utils.nu [assert-brew]

# List information about all managed services for the current use (or root.)
# Usage: brew services
export def main [subcommand: string, service?: string] {
  assert-brew
  if ($subcommand == "list" or $subcommand == 'ls' or $subcommand == null) {
    let services = ^brew services list --json
                   | from json
                   | sort-by name
                   | update status {|r|
                     if ($r.status == "none") {
                       "stopped"
                     } else {
                       $r.status
                     }
                   }
    return $services
  } else {
    return (^brew services $subcommand $service)
  }
}
