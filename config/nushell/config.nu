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


alias clr = clear

use alias-tips.nu

# alias l = "ls -a | sort-by type name -i | grid -c | str trim"

def vish []: string -> any {
  let local_autoload_dir = $nu.default_config_dir | path join "autoload"
  let local_file = $local_autoload_dir | paht join "zz_local.nu"
  if (not ($local_autoload_dir | path exists)) {
    mkdir $local_autoload_dir
  }
  if ($env | get -o EDITOR | is-empty) {
    print $"(ansi yellow_b)Please settings env EDITOR.(ansi reset)"
    return 1
  } else {
    run-external  $"($env.EDITOR)" $local_file
  }
}
alias resh = exec nu -l
