# 默认使用默认的 env.config 配置
$env.config = ($env | default {} config).config

# 更新 env.config 配置
def --env update_config [field: cell-path value: any] {
  let old_config = $env.config? | default {}
  $env.config = ($old_config | upsert $field $value)
}

update_config show_banner false
update_config ls {
  use_ls_colors: true
  clickable_links: true
}
update_config rm.always_trash true

source (if (($SOURCE_PATH | path join "config") | path expand | path exists) { "config" } else { "empty" })

alias clr = clear

use alias-tips.nu

# alias l = "ls -a | sort-by type name -i | grid -c | str trim"

def vish [] {
  if (not ($nu.cache-dir | path expand | path exists)) {
    mkdir $nu.cache-dir
  }
  if ($env | get -o EDITOR | is-empty) {
    print $"(ansi yellow_b)Please settings env EDITOR.(ansi reset)"
    return 1
  } else {
    ^$"($env.EDITOR)" ($nu.cache-dir | path join "local.nu" | path expand)
  }
}
alias resh = exec nu -l
source (if (($nu.cache-dir | path join "local.nu") | path expand |  path exists ) {
  ($nu.cache-dir | path join "local.nu") | path expand
} else {
  "empty"
})
