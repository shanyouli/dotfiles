const SPINNER_FRAMES = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
const SPINNER_DELAY = 200ms
const SPINNER_INTERVAL = 100ms
const SPINNER_WARN_SEC = 30

export const RESULT_WRITE_FAILED_CODE = -2

# Render one spinner frame on stderr.
def render-spinner [frame_index: int, remaining_sec: int, total_sec: int, message: string] {
  let frame_count = ($SPINNER_FRAMES | length)
  let frame = ($SPINNER_FRAMES | get ($frame_index mod $frame_count))
  let remaining_text = if $remaining_sec <= $SPINNER_WARN_SEC {
    $"\u{1b}[33m剩余 ($remaining_sec)s\u{1b}[0m"
  } else {
    $"剩余 ($remaining_sec)s"
  }
  let countdown = $"($remaining_text) / ($total_sec)s"
  print --stderr --raw --no-newline $"\u{1b}[2K\r($frame) ($message) ($countdown)"
}

# Clear the spinner line on stderr.
def clear-spinner [] {
  print --stderr --raw --no-newline "\u{1b}[2K\r"
}

# Run an external command with a timeout, returning its exit code and stderr.
export def run-with-timeout [
  cmd: list<string>, # Command and args; first element is the command name
  timeout_sec: int, # Timeout in seconds
  message?: string = "正在执行…" # Spinner text
] {
  let tmp_dir = (mktemp -d -t run-timeout.XXXXXX)
  let result_file = ($tmp_dir | path join "result")
  let stdout_file = ($tmp_dir | path join "stdout")
  let stderr_file = ($tmp_dir | path join "stderr")
  let started = (date now)

  let job_id = (job spawn {
    try {
      try {
        ^($cmd.0) ...($cmd | skip 1) o> $stdout_file e> $stderr_file
        # 成功路径显式写 0：LAST_EXIT_CODE 在外部命令成功时不保证被刷新
        0 | to nuon | save -f $"($result_file).tmp"
      } catch {
        $env.LAST_EXIT_CODE? | default (-1) | to nuon | save -f $"($result_file).tmp"
      }
      mv $"($result_file).tmp" $result_file
    } catch {
      try {
        $RESULT_WRITE_FAILED_CODE | to nuon | save -f $"($result_file).tmp"
        mv $"($result_file).tmp" $result_file
      } catch {
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
        # 先快照整棵进程树再 SIGTERM，避免孤儿进程事后无法定位
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
          let alive = (ps | where pid in $tree | get pid? | default [] | flatten)
          if ($alive | is-not-empty) {
            kill -f -q ...$alive
          }
        }
        if ($job_id in (job list | get id? | default [])) {
          job kill $job_id
        }
        mut waited = 0
        while ($waited < 25) and ($job_id in (job list | get id? | default [])) {
          sleep 200ms
          $waited += 1
        }
        break
      }

      if $spinner_enabled {
        let remaining_sec = ($timeout_sec - ($elapsed_sec | math floor))
        if (not $spinner_visible) and ($elapsed >= $SPINNER_DELAY) {
          render-spinner $spinner_frame $remaining_sec $timeout_sec $message
          $spinner_visible = true
        } else if $spinner_visible {
          $spinner_frame = ($spinner_frame + 1) mod ($SPINNER_FRAMES | length)
          render-spinner $spinner_frame $remaining_sec $timeout_sec $message
        }
      }

      sleep $SPINNER_INTERVAL
    }
    let stderr = if ($stderr_file | path exists) { open --raw $stderr_file } else { "" }
    { code: $code, timed_out: $timed_out, stderr: $stderr }
  } finally {
    if $spinner_enabled {
      clear-spinner
    }
    try {
      if ($job_id in (job list | get id? | default [])) {
        job kill $job_id
      }
    } catch {
    }
    rm -rf $tmp_dir
  }
}
