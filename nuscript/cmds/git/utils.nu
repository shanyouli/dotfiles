use std log

# Ensure git is installed and available in PATH.
export def assert-git [] {
  if (which git | is-empty) {
    log error "Git is not installed or not in PATH."
    exit 1
  }
}
