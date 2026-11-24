use std/log

# Check whether a path is a Git repository.
export def is-git-repo [dir_path: string]: nothing -> bool {
  try {
    let target = $dir_path | path expand
    log debug $"正在测试目录 ($target) 是否为 git 仓库"
    ((^git -C $target rev-parse --is-inside-work-tree | str trim) == "true")
  } catch {
    false
  }
}

# Get the top-level directory of a Git repository.
export def get-git-topdir [dir_path: string = ""]: nothing -> path {
  let target = $dir_path | path expand
  (^git -C $target rev-parse --show-toplevel | str trim | path expand)
}

# Get the git-dir path of a Git repository (usually .git).
export def get-git-dir [dir_path: string = ""]: nothing -> path {
  let target = $dir_path | path expand
  $target | path join (^git -C $target rev-parse --git-dir | str trim)
}
