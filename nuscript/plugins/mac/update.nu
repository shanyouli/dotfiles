use std log
use utils.nu [assert-macos]

# software update format
def software-list-format [s: string] {
  let info_lines = $s | lines --skip-empty | reduce -f { cur: "", out: [] } { |line, st|
    let l = ($line | str trim)
    if ($l | str starts-with '* Label:') {
      if $st.cur != "" {
        {
          cur: $l
          out: ($st.out | append $st.cur)
        }
      } else {
        {
          cur: $l
          out: $st.out
        }
      }
    } else if $st.cur != "" and $l != "" {
      {
        cur: $"($st.cur) ($l)"
        out: $st.out
      }
    } else {
      $st
    }
  } | update out {|st|
    if $st.cur != "" {
      $st.out | append $st.cur
    } else {
      $st.out
    }
  } | get out

  # format
  let reg_pares = '\* Label:\s*(?<label>.*)\s+Title:\s+(?<title>.*?),\s+Version:\s*(?<version>[0-9.]+),\s*Size:\s+(?<size>[0-9KiB]+),\s*Recommended:\s*(?<recommended>YES|NO),\s*Action:\s*(?<action>\w+),'
  $info_lines | each {|x| $x | parse --regex $reg_pares } | flatten
}

# macOS system software update
export def main [
  --list(-l), #"display list of available system updates"
] {
  assert-macos
  let sys_str = (^softwareupdate --list | complete).stdout
  let sys_list = if ($sys_str | str contains "Label") {
    software-list-format $sys_str
  }

  if ($sys_list | is-empty) {
    print "No system updates found."
    return
  }

  if $list {
    print $"Found ($sys_list | length) system update(s)..."
    return $sys_list
  } else {
    print "To install updates, please run: softwareupdate -i -a"
  }
}
