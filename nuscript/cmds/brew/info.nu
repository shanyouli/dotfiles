use utils.nu [assert-brew]

def info-cask [formula: string, extended?: bool] {
  try {
    mut c = ^brew info --json=v2 --casks $formula | from json | get casks
    if (not $extended) {
      $c = $c | select token name desc homepage version artifacts
           | insert type 'cask'
           | rename name application desc homepage version artifacts
           | update application { |r| $r.application | first }
           | update artifacts {|r|
             $r.artifacts
             | where {|x| ('app' in $x) or ('binary' in $x) or ('pkg' in $x)}
             | each {|x|
               if ('app' in $x) {
                 return ($x.app | first)
               }
               if ('binary' in $x) {
                 return ($x.binary | first)
               }
               if ('pkg' in $x) {
                 return ($x.pkg | first)
               }
             }
           }
      return ($c | first)
    }
  } catch {|err|
    log error $err.msg
  }
}

def info-formula [formula: string, extended?: bool] {
  try {
    mut f = ^brew info --json=v2 --formula $formula | from json | get formulae
    if (not $extended) {
      $f = $f
           | select name desc homepage license tap build_dependencies dependencies versions caveats keg_only options installed
      | insert type 'formula'
    }
    return ($f | first)
  } catch {|err|
    log error $err.msg

    print "\n"
    info-cask $formula $extended
  }
}

# Display a formula or cask's name and description.
export def desc [
  formula: string, # Formula or cask name
  --cask(-c) # Display info for cask instead of formula
] {
  let desc = if ($cask) {
    main --cask $formula
  } else {
    main $formula
  }
  return $"($desc.name): ($desc.desc)"
}

export def casks [] {
  return (^brew casks | lines | parse '{name}')
}

export def formulae [] {
  return (^brew formulae | lines | parse '{name}')
}

# Show Homebrew installation statistics, or a summary for a formula/cask.
export def main [
  formula: string, # Formula or cask name
  --extended(-e), # Show extended information
  --cask(-c) # Display info for cask instead of formula
] {
  assert-brew
  if ($cask) {
    info-cask $formula $extended
  } else {
    info-formula $formula $extended
  }
}
