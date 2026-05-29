#!/usr/bin/env nu

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
  # Test 1: mac 插件应出现在帮助列表中
  let top_help = (run-mod $BASE)
  assert-true ($top_help.stdout | str contains "mac") "m help should contain mac plugin"

  # Test 2: mac 命令列表可用
  let mac_help = (run-mod $BASE "mac")
  assert-true ($mac_help.stdout | str contains "shutdown") "mac command list should contain shutdown"
  assert-true ($mac_help.stdout | str contains "reboot") "mac command list should contain reboot"
  assert-true ($mac_help.stdout | str contains "trash") "mac command list should contain trash"
  assert-true ($mac_help.stdout | str contains "update") "mac command list should contain update"

  # Test 3: shutdown dry-run
  let shutdown_dry = (run-mod $BASE "mac" "shutdown" "--dry-run")
  assert-true ($shutdown_dry.exit_code == 0) "mac shutdown dry-run should success"
  assert-true ($shutdown_dry.stdout | str contains "osascript") "dry-run should return command string"

  print "All mac plugin smoke tests passed."
}
