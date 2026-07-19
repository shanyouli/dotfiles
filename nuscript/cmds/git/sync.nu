#!/usr/bin/env nu

use std/log

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

# 判断仓库当前是否处于 rebase 进行中状态（真冲突的可靠依据）。
# `git rev-parse --git-path` 会给出对应 rebase 状态目录的路径，
# 仅当该目录真实存在时才表示 rebase 正在进行。
def is-rebase-in-progress []: nothing -> bool {
  let merge = (^git rev-parse --git-path rebase-merge | str trim)
  let apply = (^git rev-parse --git-path rebase-apply | str trim)
  [($merge | path exists) ($apply | path exists)] | any {|it| $it }
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
    # 先同步远端引用，判断是否真的需要对本地提交做 rebase 整合。
    # 当远端相对当前 HEAD 没有尚未整合的提交时，无需 rebase 也无需临时隔离分支，
    # 直接以 HEAD:$target_branch 快进推送即可；这样可避免把脏工作区、远端分支缺失
    # 等非冲突失败误判成冲突，也省去临时分支的切换/删除开销。
    let remote_ref = $"($remote)/($target_branch)"
    let _fetch = (do -i { ^git fetch $remote $target_branch } | complete)
    let remote_ref_ok = (try { (^git rev-parse --verify --quiet $remote_ref | str trim | is-not-empty) } catch { false })
    let incoming = if (not $remote_ref_ok) { 0 } else {
      (try { (^git rev-list --count $"HEAD..($remote_ref)" | str trim | into int) } catch { 0 })
    }

    let push_result = if ($incoming > 0) {
      # 远端有新提交，需 rebase 整合：用临时分支隔离可能的冲突。
      log debug $"准备创建临时隔离分支 ($temp_branch)..."
      ^git checkout -b $temp_branch

      log debug $"远端有 ($incoming) 个新提交，正在从 ($remote_ref) 拉取并 rebase..."
      let pull_result = (do -i { ^git pull --rebase $remote $target_branch } | complete)

      if ($pull_result.exit_code != 0) {
        # 仅当 rebase 真正处于冲突态时才进入冲突处理，防止误报
        if (is-rebase-in-progress) {
          if $focus {
            log warning $"检测到冲突！已回滚 rebase 并删除临时分支 ($temp_branch)。"
            ^git rebase --abort
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

        # 非 rebase 冲突的其它失败（如工作区脏、认证/网络错误等）：
        # 如实打印 git 原始报错，并干净回滚到原分支。
        log error "git pull --rebase 失败（并非冲突），原始输出如下："
        print -e $pull_result.stderr
        ^git checkout $current_branch
        ^git branch -D $temp_branch
        exit 1
      }

      log debug $"正在推送到远程分支 ($target_branch)..."
      do -i { ^git push $remote $"($temp_branch):($target_branch)" } | complete
    } else {
      # 远端无新提交：跳过临时分支与 rebase，直接快进推送。
      log debug $"远端相对本地无新增提交，跳过 rebase，直接推送 ($remote_ref)。"
      log debug $"正在推送到远程分支 ($target_branch)..."
      do -i { ^git push $remote $"HEAD:($target_branch)" } | complete
    }

    if ($push_result.exit_code != 0) {
      log error "推送失败，原始输出如下："
      print -e $push_result.stderr
      # 仅当走 rebase 路径时才可能处于临时分支上，需要回滚并清理。
      if ($incoming > 0) {
        ^git checkout $current_branch
        let branch_lines = (^git branch | lines)
        if ($branch_lines | any {|it| ($it | str contains $temp_branch) }) {
          ^git branch -D $temp_branch
        }
      }
      exit 1
    }
    log debug "推送成功"

    # 仅当走 rebase 路径时才在临时分支上，需切回原分支并删除临时分支。
    if ($incoming > 0) {
      ^git checkout $current_branch
      let branch_lines = (^git branch | lines)
      if ($branch_lines | any {|it| ($it | str contains $temp_branch) }) {
        ^git branch -D $temp_branch
      }
    }
  } catch {|err|
    log error $err.msg
    exit 1
  }
}
