#!/usr/bin/env nu

# 代码来源 @https://github.com/nushell/nushell/discussions/13483

def print_alias_tip [found_aliases] {
  let $found_alias = $found_aliases | first

  print $"Tip: You can use the alias (ansi green_bold)($found_alias.name)(ansi reset) instead of the full command - (ansi default_bold)(ansi default_underline)($found_alias.expansion)(ansi reset)"
}

def get_all_aliases [] {
  help aliases | select name expansion
}
def is_alias [s, alias ] {
  let expansion = $alias.expansion
  (($s | str starts-with $expansion) or ($"^($s)" | str starts-with $expansion))
}
def suggest_alias [input] {
  let aliases = get_all_aliases
  let found_aliases = ($aliases | where {|alias| is_alias $input $alias })
  if ($found_aliases | length) > 0 {
    print_alias_tip $found_aliases
  }
}
def alias_tip [] {
  let command = commandline
  suggest_alias $command
}
def --env add-hook [field: cell-path new_hook: any] {
  let old_config = $env.config? | default {}
  let old_hooks = $old_config | get $field --ignore-errors | default []
  $env.config = ($old_config | upsert $field ($old_hooks ++ $new_hook))
}
export-env {
  let alias_tips_hook = { alias_tip }
  add-hook hooks.pre_execution $alias_tips_hook
}
