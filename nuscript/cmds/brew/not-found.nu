use utils.nu [assert-brew]

# command_not_found hook
export def main [cmd:string] {
  assert-brew
  if (($cmd | str contains '-h') or
      ($cmd | str contains '--help') or
      ($cmd | str contains '--usage') or
      ($cmd | str contains '-?')) {
    return null
      } else {
        ^brew which-formula --explain $cmd
  }
}
