#!/usr/bin/env nu

# 检查当前目录是否位于 Git 工作树中。
#
# 返回值：Git 返回 true 且命令执行成功时为 true，否则为 false。
def is-git-worktree []: nothing -> bool {
  try {
    let result = (do -i { ^git rev-parse --is-inside-work-tree } | complete)
    ($result.exit_code == 0 and (($result.stdout | str trim) == "true"))
  } catch {
    false
  }
}

# 输出错误信息并以非零状态终止当前命令。
#
# 参数：message - 要输出到 stderr 的错误信息。
# 返回值：不返回；始终以状态码 1 终止。
def fail [message: string]: nothing -> nothing {
  print -e $message
  exit 1
}

# 根据已暂存的文件生成提交信息并调用 pi。
#
# 参数：model/provider - 可选的 pi 模型和 provider，必须同时提供。
# 返回值：透传 pi 的退出状态。
export def main [
  --model: string
  --provider: string
] {
  let has_model = ($model != null)
  let has_provider = ($provider != null)

  if ($has_model != $has_provider) {
    fail "--model 和 --provider 必须同时传递。"
  }

  if (not (is-git-worktree)) {
    fail "当前目录不在 Git 仓库中，无法执行 gmsg。"
  }

  let staged_check = (do -i { ^git diff --cached --quiet --exit-code } | complete)
  if ($staged_check.exit_code == 0) {
    fail "没有已 git add 的文件，请先执行 git add。"
  }
  if ($staged_check.exit_code != 1) {
    let detail = ($staged_check.stderr | str trim)
    if ($detail | is-empty) {
      fail "检查 Git 暂存状态失败。"
    }
    fail $"检查 Git 暂存状态失败：($detail)"
  }

  mut pi_args = ["--no-session", "-p", "commit 当前已经 git add 的文件"]
  if $has_model {
    $pi_args = ($pi_args | append ["--model", $model, "--provider", $provider])
  }

  ^pi ...$pi_args
}

