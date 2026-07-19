use std/log
use utils.nu [assert-brew]

export use config.nu
export use deps.nu
export use doctor.nu
export use info.nu
export use leaves.nu
export use list.nu
export use not-found.nu
export use outdated.nu
export use search.nu
export use services.nu
export use shellenv.nu
export use up.nu


# 自动补全的常用 brew 命令
def "nu-complete brew" [] {
  const CURRENT_DIR = path self .
  let script_names = (ls $CURRENT_DIR
                      | get name
                      | path parse
                      | where extension == "nu"
                      | where stem != "mod" and stem != "utils"
                      | get stem
  )
  $script_names | append ["update" "upgrade" "install" "uninstall" "reinstall"]
}

# my custom brew commands.
export def --wrapped main [cmd?: string@"nu-complete brew", ...args] {
  assert-brew
  if ($cmd | is-empty) {
    print "Available commands:"
    nu-complete brew | each {|c| print $"    ($c)"}
    print "More commands, please run `brew commands`"
    return
  } else {
    ^brew $cmd ...$args
  }
}
