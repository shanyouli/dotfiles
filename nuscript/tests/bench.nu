#!/usr/bin/env nu

# Basic integration tests for bench plugin.
# Run:
#   nu tests/bench.nu

const BASE = (path self | path dirname | path dirname)

def assert-true [cond: bool, msg: string] {
  if (not $cond) {
    error make { msg: $msg }
  }
}

def run-mod [base: path, ...args: string] {
  do -i { ^nu $"($base)/mod.nu" ...$args } | complete
}

def main [] {
  # Test 1: top-level help should include bench plugin.
  let top_help = (run-mod $BASE)
  assert-true ($top_help.exit_code == 0) "m should exit with 0"
  assert-true ($top_help.stdout | str contains "bench") "m help should contain bench plugin"

  # Test 2: bench plugin help should be available.
  let bench_help = (run-mod $BASE "bench" "--help")
  assert-true ($bench_help.exit_code == 0) "m bench --help should exit with 0"
  assert-true ($bench_help.stdout | str contains "Usage") "bench help should contain Usage"
  assert-true ($bench_help.stdout | str contains "--rounds") "bench help should list --rounds"

  # Test 3: cmd as full command string should work.
  let bench_run = (run-mod $BASE "bench" "-r" "2" "-w" "0" "git status")
  assert-true ($bench_run.exit_code == 0) "m bench \"git status\" should exit with 0"

  # Test 4: quoted command path with spaces should work.
  let temp_dir = (^mktemp -d | str trim)
  let script = $"($temp_dir)/a emacs"
  [
    "#!/usr/bin/env sh"
    "echo ok"
    "exit 0"
  ] | str join (char nl) | save -f $script
  ^chmod +x $script
  let cmd_with_space = $"'($script)' --version xx"
  let bench_space = (run-mod $BASE "bench" "-r" "1" "-w" "0" $cmd_with_space)
  assert-true ($bench_space.exit_code == 0) "m bench \"'path with space' --version xx\" should exit with 0"

  print "All bench plugin tests passed."
}
