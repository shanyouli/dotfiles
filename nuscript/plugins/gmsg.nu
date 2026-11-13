#!/usr/bin/env nu

# 默认的 pi 执行超时秒数。
const DEFAULT_TIMEOUT_SEC = 300

# 终端动画的帧、提示文本与刷新节奏。
const SPINNER_FRAMES = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
const SPINNER_MESSAGE = "正在生成提交信息并提交…"
const SPINNER_DELAY = 200ms
const SPINNER_INTERVAL = 100ms

# job 内结果文件写入失败时使用的约定退出码，让主线程快速失败而不是误报超时。
const RESULT_WRITE_FAILED_CODE = -2

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

# 在 stderr 上原地绘制一帧执行动画。
#
# 参数：frame_index - 当前动画帧下标，超出帧数时自动循环。
# 返回值：不返回；会覆盖当前终端行的内容。
def render-spinner [frame_index: int] {
  let frame_count = ($SPINNER_FRAMES | length)
  let frame = ($SPINNER_FRAMES | get ($frame_index mod $frame_count))
  print --stderr --raw --no-newline $"\u{1b}[2K\r($frame) ($SPINNER_MESSAGE)"
}

# 清除 stderr 上的执行动画。
#
# 返回值：不返回；会清空当前终端行并把光标移回行首。
def clear-spinner [] {
  print --stderr --raw --no-newline "\u{1b}[2K\r"
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

# 在限时内后台运行 pi，并取回其退出码和 stderr。
#
# 用 job spawn 在后台执行 pi，stdout/stderr 重定向到临时文件避免常驻内存；
# 主线程轮询结果文件直至完成或超时；stderr 连接终端时显示原地旋转动画。
# 超时后按 SIGTERM -> SIGKILL 的顺序清理 job 内的进程，避免孤儿进程。
# 无论成功、失败还是异常，finally 都会清理动画、后台任务和临时目录。
#
# 参数：pi_args - 传给 pi 的参数列表；timeout_sec - 超时秒数。
# 返回值：包含 code（pi 退出码，被信号终止时为负值；结果文件写入失败时为
# RESULT_WRITE_FAILED_CODE）、timed_out 和 stderr（pi 的标准错误输出）的记录。
def run-pi-with-timeout [pi_args: list<string>, timeout_sec: int] {
  let tmp_dir = (mktemp -d -t gmsg-result.XXXXXX)
  let result_file = ($tmp_dir | path join "result")
  let stdout_file = ($tmp_dir | path join "stdout")
  let stderr_file = ($tmp_dir | path join "stderr")
  let started = (date now)

  let job_id = (job spawn {
    try {
      try {
        ^pi ...$pi_args o> $stdout_file e> $stderr_file
        # 成功路径显式写 0：LAST_EXIT_CODE 在外部命令成功时不保证被刷新
        0 | to nuon | save -f $"($result_file).tmp"
      } catch {
        # 非零退出、被信号终止或启动失败都会进入这里，
        # LAST_EXIT_CODE 保留外部命令的实际退出码。
        $env.LAST_EXIT_CODE? | default (-1) | to nuon | save -f $"($result_file).tmp"
      }
      mv $"($result_file).tmp" $result_file
    } catch {
      # 结果文件写入失败（如磁盘满）或与主线程清理竞态：
      # 尽力写入约定失败码，让主线程快速失败而不是白等满超时。
      try {
        $RESULT_WRITE_FAILED_CODE | to nuon | save -f $"($result_file).tmp"
        mv $"($result_file).tmp" $result_file
      } catch {
        # 临时目录已不存在等竞态，静默收尾，避免 job 错误冒泡
      }
    }
  })

  mut code: int = -1
  mut timed_out = false
  let spinner_enabled = (is-terminal --stderr)
  mut spinner_visible = false
  mut spinner_frame = 0

  try {
    loop {
      if ($result_file | path exists) {
        $code = (open --raw $result_file | into int)
        break
      }
      let elapsed = (date now) - $started
      let elapsed_sec = ($elapsed / 1sec)
      if ($elapsed_sec >= $timeout_sec) {
        $timed_out = true
        # 先快照 pi 的整棵进程树再 SIGTERM：pi 被杀后其孤儿子进程的 ppid
        # 会变成 1，事后无法再通过 ppid 定位，必须提前记录。
        let pids = (job list | where id == $job_id | get pids? | default [] | flatten)
        if ($pids | is-not-empty) {
          mut tree = $pids
          for _ in [1 2] {
            let kids = (ps | where ppid in $tree | get pid? | default [] | flatten)
            let new = ($kids | where { |p| not ($p in $tree) })
            if ($new | is-empty) { break }
            $tree = ($tree | append $new)
          }
          kill -q ...$pids
          sleep 3sec
          # 快照中仍存活的进程直接 SIGKILL
          let alive = (ps | where pid in $tree | get pid? | default [] | flatten)
          if ($alive | is-not-empty) {
            kill -f -q ...$alive
          }
        }
        # pi 被 SIGTERM 后 job 通常已自行退出并从列表移除，
        # 直接 job kill 会抛 Job not found 并中断超时兜底流程。
        if ($job_id in (job list | get id? | default [])) {
          job kill $job_id
        }
        # 等待 job 线程退出，避免与临时目录清理竞态
        mut waited = 0
        while ($waited < 25) and ($job_id in (job list | get id? | default [])) {
          sleep 200ms
          $waited += 1
        }
        break
      }

      if $spinner_enabled {
        if (not $spinner_visible) and ($elapsed >= $SPINNER_DELAY) {
          render-spinner $spinner_frame
          $spinner_visible = true
        } else if $spinner_visible {
          $spinner_frame = ($spinner_frame + 1) mod ($SPINNER_FRAMES | length)
          render-spinner $spinner_frame
        }
      }

      sleep $SPINNER_INTERVAL
    }
    let stderr = if ($stderr_file | path exists) { open --raw $stderr_file } else { "" }
    { code: $code, timed_out: $timed_out, stderr: $stderr }
  } finally {
    # 无论成功、失败还是异常，都清理动画、后台任务和临时目录
    if $spinner_enabled {
      clear-spinner
    }
    try {
      if ($job_id in (job list | get id? | default [])) {
        job kill $job_id
      }
    } catch {
      # job 可能刚好自行退出
    }
    rm -rf $tmp_dir
  }
}

# 根据已暂存的文件生成提交信息并调用 pi。
#
# --model 与 --provider 必须成对传递；-t/--timeout 限制 pi 执行时长（秒）。
# pi 执行期间会在终端显示旋转动画；通过 HEAD 是否变化判定是否生成了新提交，
# 成功后显示新提交的 ID 和标题。超时被终止后若已生成新提交则视为提交成功，
# 并透传 pi 被终止前的 stderr；否则提示切换模型。
export def main [
  --model(-m): string
  --provider(-p): string
  --timeout(-t): int = $DEFAULT_TIMEOUT_SEC
] {
  let has_model = ($model != null)
  let has_provider = ($provider != null)

  if ($has_model != $has_provider) {
    fail "--model 和 --provider 必须同时传递。"
  }

  if ($timeout < 1) {
    fail "--timeout 必须 ≥ 1 秒。"
  }

  if (not (is-git-worktree)) {
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

  let result = (run-pi-with-timeout $pi_args $timeout)
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
