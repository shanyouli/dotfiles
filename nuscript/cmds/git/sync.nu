#!/usr/bin/env nu

use std log

# Check whether a path is a Git repository.
def is-git-repo [dir_path: string]: nothing -> bool {
  try {
    let target = $dir_path | path expand
    log debug $"test ($target) 是否为 git 仓库"
    ((^git -C $target rev-parse --is-inside-work-tree | str trim) == "true")
  } catch {
    false
  }
}

# Sync local changes to remote branch through a temporary branch.
# Usage:
#   m git sync [branch] [-r origin] [-d /path/to/repo] [--debug] [--focus]
export def main [
  branch: string = "", # target branch to sync into
  --remote(-r): string = "origin", # remote name
  --dir(-d): string = "", # target repository dir, default current dir
  --debug, # enable debug logs
  --focus(-f) # on conflict: force cleanup temporary branch and exit
] {
  if $debug {
    log set-level 10
  }

  let target_dir = if ($dir | is-empty) { (pwd) } else { ($dir | path expand) }
  if (not (is-git-repo $target_dir)) {
    log error $"当前路径 ($target_dir) 不是一个 git 仓库。"
    exit 1
  }

  cd $target_dir

  let current_branch = (^git branch --show-current | str trim)
  let temp_branch = $"sync-temp-(date now | format date '%H%M%S')"
  let target_branch = if ($branch | is-empty) {
    if ($current_branch in ["master", "main"]) { $current_branch } else { "main" }
  } else {
    $branch
  }

  try {
    log debug $"准备创建临时隔离分支 ($temp_branch)..."
    ^git checkout -b $temp_branch

    log debug $"正在从 ($remote)/($target_branch) 拉取并 rebase..."
    let pull_result = (do -i { ^git pull --rebase $remote $target_branch } | complete)

    if ($pull_result.exit_code != 0) {
      if $focus {
        log warning $"检测到冲突！强制删除临时分支 ($temp_branch)。"
        ^git checkout $current_branch
        ^git branch -D $temp_branch
      } else {
        log warning "检测到冲突！已切换到手动模式。"
        log warning $"你的原始分支未被改动: ($current_branch)"
        log warning $"请在当前分支 ($temp_branch) 解决冲突后执行:"
        log warning $"  git add . && git rebase --continue && git push ($remote) ($target_branch)"
        log warning "处理完成后，记得切回原分支并删除临时分支。"
      }
      exit 1
    }

    log debug $"正在推送到远程分支 ($target_branch)..."
    ^git push $remote $"($temp_branch):($target_branch)"
    log debug "推送成功"

    ^git checkout $current_branch
    let branch_lines = (^git branch | lines)
    if ($branch_lines | any {|it| ($it | str contains $temp_branch) }) {
      ^git branch -D $temp_branch
    }
  } catch {|err|
    log error $err.msg
    exit 1
  }
}
