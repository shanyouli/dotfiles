use std log

# Ensure Homebrew is installed and available in PATH.
export def assert-brew [] {
  if (which brew | is-empty) {
    log error "Homebrew is not installed or not in PATH. Please install it from https://brew.sh/"
    exit 1
  }
}
