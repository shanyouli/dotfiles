#!/usr/bin/env nu

# Basic integration tests for brew plugin.
# Run:
#   nu tests/brew.nu

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
  # Test 1: top-level help should include brew plugin.
  let top_help = (run-mod $BASE)
  assert-true ($top_help.exit_code == 0) "m should exit with 0"
  assert-true ($top_help.stdout | str contains "brew") "m help should contain brew plugin"

  # Test 2: brew plugin command list should be available.
  let brew_help = (run-mod $BASE "brew")
  assert-true ($brew_help.exit_code == 0) "m brew should exit with 0"
  assert-true ($brew_help.stdout | str contains "Available commands:") "m brew should print command list"
  assert-true ($brew_help.stdout | str contains "list") "m brew output should contain list"
  assert-true ($brew_help.stdout | str contains "outdated") "m brew output should contain outdated"

  # Test 3: list subcommand help should be available.
  let list_help = (run-mod $BASE "brew" "list" "--help")
  assert-true ($list_help.exit_code == 0) "m brew list --help should exit with 0"
  assert-true ($list_help.stdout | str contains "Usage") "list help should contain Usage"
  assert-true ($list_help.stdout | str contains "--extended") "list help should list --extended"

  # Test 4: info subcommand help should be available.
  let info_help = (run-mod $BASE "brew" "info" "--help")
  assert-true ($info_help.exit_code == 0) "m brew info --help should exit with 0"
  assert-true ($info_help.stdout | str contains "Usage") "info help should contain Usage"
  assert-true ($info_help.stdout | str contains "--cask") "info help should list --cask"

  print "All brew plugin tests passed."
}

