#!/usr/bin/env nu
use std/log

# 判断目录是否为 Git 仓库
def is-git-repo [dir_path: string = ""]: nothing -> bool {
  try {
    let target = $dir_path | path expand
    log debug $"正在测试目录 ($target) 是否为 git 仓库"
    ((^git -C $target rev-parse --is-inside-work-tree | str trim) == "true")
  } catch {
    false
  }
}

# 获取 Git 根目录
def get-git-topdir [dir_path: string = ""]: nothing -> path {
  let target = $dir_path | path expand
  (^git -C $target rev-parse --show-toplevel | str trim | path expand)
}

# 获取当前 git 仓库的 git-dir 文件，一般为 .git
def get-git-dir [dir_path: string = ""]: nothing -> path {
  let target = $dir_path | path expand
  $target | path join (^git -C $target rev-parse --git-dir | str trim)
}

# 计算 Git 元数据占用大小
def du-git-repo [dir_path: string = ""]: nothing -> filesize {
  try {
    du (get-git-dir $dir_path) | get physical | math sum
  } catch {
    0b
  }
}

def is-git-url [url: string]: nothing -> any {
  let parsed = (
    $url
    | parse -r '^(?P<proto>https?://|ssh://|git@)(?P<host>[^:/]+)[:/]?(?P<path>.*)/(?P<name>[^/:]+?)(?:\.git)?/?$'
  )
  if ($parsed | is-empty) { null } else { $parsed.0.name }
}

export def main [
  url: string = "", # 克隆链接或本地路径
  dir_path: string = "", # 本地目录（可选）
  --force(-f), # 强制删除本地 tag/分支
  --debug(-d), # 输出详细日志
  --remote(-r) # 获取远程最新提交后压缩
] {
  if $debug { log set-level 10 }

  mut target_dir = ""
  if ($url | is-not-empty) {
    let repo_name = (is-git-url $url)
    if ($repo_name | is-not-empty) {
      $target_dir = (if ($dir_path | is-empty) { $repo_name } else { $dir_path }) | path expand
      mkdir ($target_dir | path dirname)
      if ($target_dir | path exists) {
        log error $"($target_dir) 已经存在，无法克隆。"
        exit 1
      }

      log info $"开始克隆 ($url)..."
      ^git clone --depth 1 $url $target_dir
      log info "克隆完成"

      let real_path = if ($target_dir | str starts-with $env.PWD) {
        $target_dir | path relative-to $env.PWD
      } else {
        $target_dir
      }
      let size = du-git-repo $target_dir
      log info $"($real_path) 仓库的 .git 大小：($size)"
      return $size
    } else {
      $target_dir = $url | path expand
    }
  } else {
    $target_dir = if ($dir_path | is-empty) { (pwd) } else { ($dir_path | path expand) }
  }

  if (not (is-git-repo $target_dir)) {
    log error $"当前路径 [($target_dir)] 不是一个 git 仓库."
    exit 1
  }

  let git_dir = get-git-topdir $target_dir
  let initial_size = du-git-repo $git_dir
  log info $"($git_dir) .git 仓库大小: ($initial_size)"

  cd $git_dir
  let main_branch = (^git rev-parse --abbrev-ref HEAD | str trim)

  if $remote {
    ^git fetch --depth 1 origin $main_branch

    if $force {
      let tags = (^git tag -l --sort=creatordate | lines)
      if ($tags | is-not-empty) {
        $tags | each {|t| ^git tag -d $t }
      }
      let local_branches = (
        ^git branch
        | lines
        | each {|b| $b | str trim | str replace -r '^\*\s+' '' }
        | where {|b| $b != $main_branch}
      )
      if ($local_branches | is-not-empty) {
        $local_branches | each {|b| ^git branch -D $b }
      }
    } else {
      log info "正在清理旧标签，仅保留最新一个..."
      let tags = (^git tag -l --sort=creatordate | lines)
      if (($tags | length) > 1) {
        let newest_tag = ($tags | last)
        $tags
        | where {|t| $t != $newest_tag}
        | each {|t|
          log debug $"删除旧标签: ($t)"
          ^git tag -d $t
        }
      } else {
        log debug "只有一个标签或无标签，无需清理。"
      }
    }
  } else {
    ^git reset --hard HEAD
    ^git clean -ffd
    try {
      ^git replace --graft HEAD
    } catch {
      log info $"($env.PWD) 已经是 compact 状态"
    }

    ^git tag -l | lines | each {|t| ^git tag -d $t }

    let local_branches = (
      ^git branch
      | lines
      | each {|b| $b | str trim | str replace -r '^\*\s+' '' }
      | where {|b| $b != $main_branch}
    )
    if ($local_branches | is-not-empty) {
      $local_branches | each {|b| ^git branch -D $b }
    }

    let remote_branches = (
      ^git branch -r
      | lines
      | each {|b| $b | str trim }
      | where {|b| (not ($b | str contains "->")) and (not ($b | str ends-with $main_branch))}
    )
    if ($remote_branches | is-not-empty) {
      $remote_branches | each {|b| ^git branch -r -d $b }
    }
  }

  try {
    if $force {
      ^git repack -a -d -f -F --window=250 --depth=250
    }
    ^git reflog expire --expire=now --all
    ^git gc --prune=now --aggressive --force
  } catch {
    log warning "repack/gc 执行异常，已跳过。"
  }

  let final_size = du-git-repo $target_dir
  log info $"清理后 .git 目录大小: ($final_size)"
  let saved_size = $initial_size - $final_size
  log info $"共节省了约: (ansi defd)(ansi defu)($saved_size)(ansi reset)"
  $saved_size
}
