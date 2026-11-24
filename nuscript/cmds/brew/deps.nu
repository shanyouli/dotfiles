use utils.nu [assert-brew]

# Show dependencies for a formula, or all installed formulae.
export def main [
  formula?: string # Formula/e to show dependencies for
] {
  assert-brew
  mut res = null
  if ($formula != null) {
    $res = ^brew deps $formula --include-requirements --topological
    return ($res | lines)
  } else {
    $res = ^brew deps --installed --topological
    return (
      $res
      | lines
      | parse "{name}: {dependencies}"
      | update dependencies {|e| $e.dependencies | split row ' '}
    )
  }
}

# Check a formula for missing dependencies.
export def missing [
  formula: string # Formula/e to check for missing dependencies
] {
  ^brew deps $formula --missing | lines | parse "{name}: {dependencies}"
}

# Show a dependency tree for a formula, or all installed formulae.
export def tree [
  formula?: string # Formula/e to show dependencies for
] {
  mut res = null
  if ($formula != null) {
    $res = ^brew deps $formula --include-requirements --topological --tree
  } else {
    $res = ^brew deps --installed --include-requirements --topological --tree
  }
  return $res
}
