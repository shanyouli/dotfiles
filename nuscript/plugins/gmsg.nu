#!/usr/bin/env nu

use ../lib/git.nu [is-git-repo]
use ../lib/process.nu [RESULT_WRITE_FAILED_CODE run-with-timeout]

# 默认的 pi 执行超时秒数。
const DEFAULT_TIMEOUT_SEC = 300

# 输出错误信息并以非零状态终止当前命令。
#
# 参数：message - 要输出到 stderr 的错误信息。
# 返回值：不返回；始终以状态码 1 终止。
def fail [message: string]: nothing -> nothing {
  print -e $message
  exit 1
}

# 读取指定 commit 的 `git log -1 --oneline` 摘要。
#
# 参数：commit_id - 要读取的 commit id。
# 返回值：非空摘要字符串；读取失败或摘要为空时返回空字符串。
def get-commit-summary [commit_id: string]: nothing -> string {
  let result = (do -i { ^git log -1 --oneline $commit_id } | complete)
  if ($result.exit_code == 0) {
    $result.stdout | str trim
  } else {
    ""
  }
}

# 输出指定 commit 的简短 ID 和标题。
#
# 参数：commit_id - 要展示的 commit id。
# 返回值：不返回；成功时把摘要输出到 stdout，读取失败时以状态码 1 终止。
def show-commit-summary [commit_id: string] {
  let summary = (get-commit-summary $commit_id)
  if ($summary | is-empty) {
    fail $"读取 commit ($commit_id) 失败。"
  }
  print $summary
}

# 读取当前 HEAD 指向的 commit id。
#
# 返回值：HEAD 的完整 commit id；仓库没有任何提交（unborn HEAD）时返回空字符串，
# 读取失败时返回 null。
def get-head-commit []: nothing -> any {
  let result = (do -i { ^git rev-parse HEAD } | complete)
  if ($result.exit_code == 0) {
    $result.stdout | str trim
  } else if ($result.stderr | str contains "unknown revision") {
    # unborn HEAD：仓库还没有任何提交
    ""
  } else {
    null
  }
}

# 根据已暂存的文件生成提交信息并调用 pi。
export def main [
  --model(-m): string, # 传给 pi 的模型名
  --provider(-p): string, # 传给 pi 的 provider 名
  --timeout(-t): int = $DEFAULT_TIMEOUT_SEC # pi 执行超时秒数
] {
  let has_model = ($model != null)
  let has_provider = ($provider != null)

  if ($has_model != $has_provider) {
    fail "--model 和 --provider 必须同时传递。"
  }

  if ($timeout < 1) {
    fail "--timeout 必须 ≥ 1 秒。"
  }

  if (not (is-git-repo (pwd))) {
    fail "当前目录不在 Git 仓库中，无法执行 gmsg。"
  }

  # 提前预检，避免 ^pi 启动失败被 job 内 catch 静默吞掉后白等满超时。
  if (which pi | is-empty) {
    fail "找不到 pi 命令，请确认已安装并在 PATH 中。"
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

  # 记录执行前的 HEAD，用于判定 pi 是否真的创建了新提交
  let head_before = (get-head-commit)

  mut pi_args = ["--no-session", "-p", "commit 当前已经 git add 的文件"]
  if $has_model {
    $pi_args = ($pi_args | append ["--model", $model, "--provider", $provider])
  }

  let result = (run-with-timeout (["pi" ...$pi_args]) $timeout "正在生成提交信息并提交…")
  let head_after = (get-head-commit)

  if (not $result.timed_out) {
    if ($result.code == 0) {
      if ($head_after | is-empty) {
        if ($head_after == null) {
          fail "读取 HEAD 失败，无法判定 pi 是否创建了新提交。"
        }
        fail "pi 执行成功，但没有检测到新的 commit。"
      }
      if ($head_after == $head_before) {
        fail "pi 执行成功，但没有检测到新的 commit。"
      }
      show-commit-summary $head_after
    } else if ($result.code == $RESULT_WRITE_FAILED_CODE) {
      fail "读取 pi 执行结果失败，结果文件写入异常。"
    } else {
      let err_text = ($result.stderr | str trim)
      if ($err_text | is-empty) {
        print -e $"pi 执行失败，退出码 ($result.code)。"
      } else {
        print -e $err_text
      }
      # pi 可能在失败前已经创建了提交，提示用户避免困惑
      if (($head_after | is-not-empty) and ($head_after != $head_before)) {
        let summary = (get-commit-summary $head_after)
        if ($summary | is-not-empty) {
          print -e $"注意：pi 失败前已创建提交：($summary)"
        }
      }
    }
    exit $result.code
  }

  # 超时：pi 可能已经完成 commit 但未来得及退出，用 HEAD 是否变化判定实际结果。
  # 透传 pi 被终止前的 stderr，便于排查挂起原因。
  let pi_err = ($result.stderr | str trim)
  if ($pi_err | is-not-empty) {
    print -e "pi 被终止前的 stderr 输出："
    print -e $pi_err
  }
  if (($head_after | is-not-empty) and ($head_after != $head_before)) {
    print -e $"pi 执行超过 ($timeout) 秒被强制终止，但已生成新的 commit，视为提交成功。"
    show-commit-summary $head_after
    return
  }
  fail "pi 执行超时被强制终止，没有生成 commit 信息，请切换 model 后重试。"
}
