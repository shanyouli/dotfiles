use utils.nu [assert-brew]

# List all managed services for the current user (or root).
export def main [
  subcommand: string, # brew services subcommand (e.g. list)
  service?: string # Service name
] {
  assert-brew
  if ($subcommand == "list" or $subcommand == 'ls') {
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
