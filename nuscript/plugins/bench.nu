#!/usr/bin/env nu

use std/bench
use ../lib/shell.nu [split-cmd]

# Benchmark an external command.
export def --wrapped main [
  cmd: string, # Full command string to benchmark
  --rounds(-r): int = 5, # Number of benchmark rounds
  --warmup(-w): int = 3, # Number of warmup rounds
  --pretty(-p), # Pretty-print the result
  ...args: string # Extra args appended after `--`
] {
  let parsed = split-cmd $cmd
  if ($parsed | is-empty) {
    error make { msg: "bench: cmd is empty after parsing" }
  }

  let has_sep = (($args | length) > 0) and (($args | first) == "--")
  let extra_args = if $has_sep { ($args | skip 1) } else { $args }

  let rounds_n = $rounds
  let warmup_n = $warmup
  let command = ($parsed | first)
  let command_args = (($parsed | skip 1) | append $extra_args)

  if $pretty {
    bench -n $rounds_n -w $warmup_n --pretty { ^$command ...$command_args | ignore }
  } else {
    bench -n $rounds_n -w $warmup_n { ^$command ...$command_args | ignore }
  }
}
