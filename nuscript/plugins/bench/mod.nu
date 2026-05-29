#!/usr/bin/env nu

use std/bench

# Split a command string into argv.
# Supports spaces and single/double quotes.
def split-cmd [text: string]: nothing -> list<string> {
  mut tokens = []
  mut current = ""
  mut quote = ""

  for ch in ($text | split chars) {
    if ($quote | is-empty) {
      if ($ch == "'" or $ch == "\"") {
        $quote = $ch
      } else if ($ch == " " or $ch == "\t" or $ch == "\n") {
        if ($current | is-not-empty) {
          $tokens = ($tokens | append $current)
          $current = ""
        }
      } else {
        $current = $"($current)($ch)"
      }
    } else {
      if $ch == $quote {
        $quote = ""
      } else {
        $current = $"($current)($ch)"
      }
    }
  }

  if ($quote | is-not-empty) {
    error make { msg: "bench: unmatched quote in cmd" }
  }
  if ($current | is-not-empty) {
    $tokens = ($tokens | append $current)
  }

  $tokens
}

def show-help [] {
  print "Usage:"
  print "  m bench [--rounds|-r N] [--warmup|-w N] [--pretty|-p] <cmd>"
  print "  m bench [--rounds|-r N] [--warmup|-w N] [--pretty|-p] <cmd> -- [extra-args]"
  print ""
  print "cmd is a full command string parsed by shell."
  print "Examples:"
  print "  m bench \"git status\""
  print "  m bench \"'./xx/a emacs' --version xx\""
  print "  m bench -r 100 -w 5 --pretty \"ls\" -- -la"
}

# Benchmark an external command.
# Usage:
#   m bench "git status"
#   m bench "'./xx/a emacs' --version xx"
export def --wrapped main [
  cmd: string,
  --rounds(-r): int = 5,
  --warmup(-w): int = 3,
  --pretty(-p),
  ...args: string
] {
  if ($cmd == "-h" or $cmd == "--help") {
    show-help
    return
  }

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
