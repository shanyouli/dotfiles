#!/usr/bin/env nu

# 默认的 pi 执行超时秒数。
const DEFAULT_TIMEOUT_SEC = 300

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

# 在限时内后台运行 pi，并取回其退出码。
#
# 用 job spawn 在后台执行 pi，主线程轮询结果文件直至超时；
# 超时后按 SIGTERM -> SIGKILL 的顺序清理 job 内的进程，避免孤儿进程。
#
# 参数：pi_args - 传给 pi 的参数列表；timeout_sec - 超时秒数。
# 返回值：包含 code（pi 退出码，被信号终止时为负值）和 timed_out 的记录。
def run-pi-with-timeout [pi_args: list<string>, timeout_sec: int] {
  let tmp_dir = (mktemp -d -t gmsg-result.XXXXXX)
  let result_file = ($tmp_dir | path join "result")
  let started = (date now)

  let job_id = (job spawn {
    try {
      let r = (do { ^pi ...$pi_args } | complete)
      let tmp = ($"($result_file).tmp")
      $r.exit_code | to nuon | save -f $tmp
      mv $tmp $result_file
    } catch {
      # 被信号终止或清理竞态时静默收尾，避免 job 错误冒泡到主线程
    }
  })

  mut code: int = -1
  mut timed_out = false
  loop {
    if ($result_file | path exists) {
      $code = (open --raw $result_file | into int)
      break
    }
    let elapsed = ((date now) - $started) / 1sec
    if ($elapsed >= $timeout_sec) {
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
    sleep 500ms
  }

  rm -rf $tmp_dir
  { code: $code, timed_out: $timed_out }
}

# 根据已暂存的文件生成提交信息并调用 pi。
#
# --model 与 --provider 必须成对传递；-t/--timeout 限制 pi 执行时长（秒）。
# 超时被终止后，若工作区已无未提交变更则视为提交成功，否则提示切换模型。
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

  mut pi_args = ["--no-session", "-p", "commit 当前已经 git add 的文件"]
  if $has_model {
    $pi_args = ($pi_args | append ["--model", $model, "--provider", $provider])
  }

  let result = (run-pi-with-timeout $pi_args $timeout)
  if (not $result.timed_out) {
    exit $result.code
  }

  # 超时：pi 可能已经完成 commit 但未来得及退出，用 git status 判定实际结果。
  # 排除未跟踪文件：commit 只影响已跟踪文件，pi 运行残留的 untracked 不代表未提交。
  let status = (do -i { ^git status --porcelain --untracked-files=no } | complete)
  if ($status.exit_code != 0) {
    fail $"检查 Git 状态失败：($status.stderr | str trim)"
  }
  if (($status.stdout | str trim) | is-empty) {
    print -e "pi 执行超过 ($timeout) 秒被强制终止，但工作区已无未提交变更，视为提交成功。"
    return
  }
  fail "pi 执行超时被强制终止，没有生成 commit 信息，请切换 model 后重试。"
}
