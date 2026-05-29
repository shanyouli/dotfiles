#!/usr/bin/env nu

# Basic integration tests for git plugin commands.
# Run:
#   nu tests/git.nu

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
  # Test 1: plugin command list contains sync/shallow.
  let git_help = (run-mod $BASE "git")
  assert-true ($git_help.exit_code == 0) "m git should exit with 0"
  assert-true ($git_help.stdout | str contains "sync") "m git output should contain sync"
  assert-true ($git_help.stdout | str contains "shallow") "m git output should contain shallow"

  # Test 2: shallow help is available.
  let shallow_help = (run-mod $BASE "git" "shallow" "--help")
  assert-true ($shallow_help.exit_code == 0) "m git shallow --help should exit with 0"
  assert-true ($shallow_help.stdout | str contains "Usage") "shallow help should contain Usage"
  assert-true ($shallow_help.stdout | str contains "--force") "shallow help should list --force"

  # Test 3: shallow should fail on a non-git directory.
  let temp_dir = (^mktemp -d | str trim)
  let shallow_fail = (run-mod $BASE "git" "shallow" $temp_dir)
  assert-true ($shallow_fail.exit_code != 0) "m git shallow <non-git-dir> should fail"

  print "All git plugin tests passed."
}
