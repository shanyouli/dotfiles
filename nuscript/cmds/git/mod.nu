export use sync.nu
export use shallow.nu
use utils.nu [assert-git]

# Common git command completion
def "nu-complete git" [] {
  [sync shallow status log diff checkout branch pull push fetch]
}

# Git custom commands
export def --wrapped main [cmd?: string@"nu-complete git", ...args] {
  assert-git
  if ($cmd | is-empty) {
    print "Available git commands:"
    nu-complete git | each {|c| print $"    ($c)"}
    return
  } else {
    ^git $cmd ...$args
  }
}
