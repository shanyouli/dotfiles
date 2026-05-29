export use shutdown.nu
export use reboot.nu
export use trash.nu
export use update.nu
export use wifi.nu

# 自动补全的常用 mac 命令
def "nu-complete mac" [] {
  const CURRENT_DIR = path self .
  ls $CURRENT_DIR
  | get name
  | path parse
  | where extension == "nu"
  | where stem != "mod" and stem != "utils"
  | get stem
}

# macOS custom commands
export def --wrapped main [cmd?: string@"nu-complete mac", ...args] {
  if ($cmd | is-empty) {
    print "Available commands:"
    nu-complete mac | each {|c| print $"    ($c)"}
    return
  } else {
    # 逻辑由 mod.nu 自动处理分发
    # 如果通过 m mac <cmd> 调用，m 的顶层逻辑会优先寻找同名文件
  }
}
