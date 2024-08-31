#!/usr/bin/env nu

# rye manager global python command line.
export def --wrapped "rye tools install" [ ...rest ] {
  let python_version = ^rye config --get default.toolchain
  let is_default = ($python_version == "?") or (not ($python_version =~ '.*@[0-9.]+'))
  for $i in $rest {
    if ($i | str starts-with "--python") or ($i | str starts-with "-p") {
      let is_default = true
      break
    }
  }
  if $is_default {
    ^rye tools install ...$rest
  } else {
    ^rye tools install --python $python_version ...$rest
  }
}

export alias "rye install" = rye tools install
export alias pipx = rye tools install
