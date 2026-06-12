#!/usr/bin/env nu

export use list.nu
export use show.nu

# Return available subcommands for cc-switch plugin completion.
def "nu-complete cc-switch" [] {
  const current_dir = (path self | path dirname)
  ls $current_dir
  | get name
  | path parse
  | where extension == "nu"
  | where stem != "mod"
  | get stem
}

# Show plugin help or delegate execution to subcommands via the top-level router.
#
# Parameters:
# - cmd: Optional subcommand name.
# - ...args: Remaining arguments passed by the router.
#
# Returns:
# - Prints available subcommands when no command is provided.
#
# Side effects:
# - Writes help text to stdout.
export def --wrapped main [cmd?: string@"nu-complete cc-switch", ...args] {
  if ($cmd | is-empty) {
    print "Available commands:"
    nu-complete cc-switch | each {|command| print $"    ($command)"}
    return
  }
}
