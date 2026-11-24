# Split a command string into argv, supporting single/double quotes.
export def split-cmd [text: string]: nothing -> list<string> {
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
    error make { msg: "split-cmd: unmatched quote in cmd" }
  }
  if ($current | is-not-empty) {
    $tokens = ($tokens | append $current)
  }

  $tokens
}
