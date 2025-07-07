#!/usr/bin/env nu

def "nu-completion gopass commands" [] {
  ^gopass help
  | lines --skip-empty
  | skip while { |line| (not ( $line | str starts-with "COMMANDS") ) }
  | take while { |line| (not ($line | str starts-with "GLOBAL"))}
  | where { str starts-with "  " }
  | str trim
  | parse --regex '(?P<value>[^,\s]+).*\s{2,}(?P<description>.+)'
}

export extern "gopass" [
  command?: string@"nu-completion gopass commands"
  --yes(-y)                    # Always answer yes to yes/no questions (default: false)
  --clip(-c)                   # Copy the password value into the clipboard (default: false)
  --alsoclip(-C)               # Copy the password and show everything (default: false)
  --qr                         # Print the password as a QR Code (default: false)
  --unsafe(-u)                 # Display unsafe content (e.g. the password) even if safecontent is enabled (default: false)
  --force(-f)                  # Display unsafe content (e.g. the password) even if safecontent is enabled (default: false)
  --password(-o)               # Display only the password. Takes precedence over all other flags. (default: false)
  --revision(-r): string       # Show a past revision. Does NOT support RCS specific shortcuts. Use exact revision or -<N> to select the Nth oldest revision of this entry.
  --noparsing(-n)              # Do not parse the output. (default: false)
  --nosync                     # Disable auto-sync (default: false)
  --chars: string              # Print specific characters from the secret
  --help(-h)                   # show help
  --version(-v)                # print the version
]

def "nu-completion gopass templates" [] {
  ^gopass templates --help
  | lines --skip-empty
  | skip while { |line| (not ( $line | str starts-with "COMMANDS") ) }
  | take while { |line| (not ($line | str starts-with "OPTIONS"))}
  | where { str starts-with "  " }
  | str trim
  | parse --regex '(?P<value>[^,\s]+).*\s{2,}(?P<description>.+)'

}

export extern "gopass templates" [
  command?: string@"nu-completion gopass templates"
  --help(-h)                   # show help
]

def "nu-completion gopass secrets" []: nothing -> list<string> {
  ^gopass list --flat | lines
}

def "nu-completion gopass folders" []: nothing -> list<string> {
  ^gopass list --flat --folders | lines
}

def "nu-completion gopass folders secrets" [] {
  nu-completion gopass folders | append (nu-completion gopass secrets)
}

export extern "gopass sync" [
  --store(-s): string   # select the store to sync
  --help(-h):           # show help
]

export extern "gopass sum" [
  secret: string@"nu-completion gopass secrets"   # show secret sha256
  --help(-h)                                      # show help
]

export extern "gopass show" [
  secret: string@"nu-completion gopass secrets"  # show secret name
]

export extern "gopass setup" [
  --remote: string      # URL to a git remote, will attempt to join this team
  --aliase: string      # Local mount point for the given remote
  --create              # Create a new team (default: false, i.e. join an existing team)
  --name: string        # Firstname and Lastname for unattended GPG key generation
  --email: string       # EMail for unattended GPG key generation
  --crypto: string      # Select crypto backedn [age gpgcli plain]
  --storage: string     # Select storage backedn [fossilfs fs gitfs]
  --help(-h)            # show help
]

def "nu-completion gopass recipients" [] {
  ^gopass recipients --help
  | lines --skip-empty
  | skip while { |line| (not ( $line | str starts-with "COMMANDS") ) }
  | take while { |line| (not ($line | str starts-with "OPTIONS"))}
  | where { str starts-with "  " }
  | str trim
  | parse --regex '(?P<value>[^,\s]+).*\s{2,}(?P<description>.+)'
}

export extern "gopass recipients" [
  command?: string@"nu-completion gopass recipients"
  --pretty                                          # Pretty print recipients (default: true)
  --help(-h)                                        # show help
]

export extern "gopass otp" [
  secret: string@"nu-completion gopass secrets"
  --clip(-c)          # copy the time-based token into the clipboard (default: false)
  --qr(-q): string    # write QR Code to FILE
  --password(-o)      # only display the token (default: false)
  --snip(-s)          # scan screen content to insert a OTP QR code into provided entry (default: false)
  --help(-h)          # show help
]

export extern "gopass pwgen" [
  length?: int
  --no-numerals(-0)     # Do not include numerals in the generated passwords. (default: false)
  --no-capitalize(-A)   # Do not include capital letter in the generated passwords. (default: false)
  --ambiguous(-B)       # Do not include characters the could be easily confused with each other, like '1' and 'l' (default: false)
  --symbols(-y)         # Include at least one symbol in password (default: false)
  --one-per-line(-1)    # Print one password per line (default: false)
  --xkcd(-x)            # Use multiple random english words combind to a password
  --sep: string         # word separator for generated xkcd style password.
  --lang: string        # Language to generate password from. crrrently only en.
  --xkcdcapitalize      # capitalize first letter of each word in generated xkcd style.
  --xkcdnumbers         # add a random number to the end of the generated xkcd style.
  --help(-h)            # show help
]

export extern "gopass move" [
  from: string@"nu-completion gopass secrets" 
  to: string@"nu-completion gopass folders"
  --force(-f)           # Force to move the secret and overwrite existing one 
  --help(-h)            # show help
]

def "nu-completion gopass mounts" [] {
  ^gopass mounts --help
  | lines --skip-empty
  | skip while { |line| (not ( $line | str starts-with "COMMANDS") ) }
  | take while { |line| (not ($line | str starts-with "OPTIONS"))}
  | where { str starts-with "  " }
  | str trim
  | parse --regex '(?P<value>[^,\s]+).*\s{2,}(?P<description>.+)'
}
export extern "gopass mounts" [
  subcommand?: string@"nu-completion gopass mounts"
  --help(-h)         # show help
]

export extern "gopass merge" [
  to: string@"nu-completion gopass secrets"
  ...from: string@"nu-completion gopass secrets"
  --delete(-d)    # remove merged entries (default: true)
  --force(-f)     # skip editor, merge entries unattended
  --help(-h)      # show help
]

export extern "gopass list" [
  --limit(-l): int   # display no more than this many levels of the tree(default: 0)
  --flat(-f)         # print a flat list
  --folders(-d)      # print a flat list of folders
  --strip-prefix(-s) # strip this prefix from filtered entries
  --help(-h)         # show help
]

export extern "gopass insert" [
  secret?: string@"nu-completion gopass folders secrets"
  --each(-e)      # Display secret while typing
  --multiline(-m) # insert using $EDITOR
  --force(-f)     # overwrite any existing secret and do not prompt to confirm recipients
  --append(-a)    # append data read from STDIN to existing data
  --help(-h)      # show help
]

def "nu-completion gopass crypto type" [] {
  ["age" "gpgcli" "plain"]
}
def "nu-completion gopass storage type" [] {
  ["fossilfs" "gitfs" "fs"]
}
export extern "gopass init" [
  --path(-p): string                                     # set the sub-store path to operate on
  --store(-s): string                                    # set the name of the sub-store
  --crypto: string@"nu-completion gopass crypto type"     # select crypto backend (default: "gpgcli")
  --storage: string@"nu-completion gopass storage type"  # select storage backend (default: "gitfs")
  --help(-h)                                             # show help
]

export extern "gopass history" [
  secret?: string@"nu-completion gopass secrets"
  --password(-p) # Include passwords in output
  --help(-h)     # show help
]

export extern "gopass grep" [
  --regexp(-r)  # Interpret pattern as RE2 regular expression
  --help(-h)    # show help
]

def "nu-completion gopass generator" [] {
  ["cryptic" "memorable" "xkcd" "external"]
}

export extern "gopass gerate" [
  secret?: string@"nu-completion gopass folders secrets"
  --clip(-c)              # copy the generated password to the clipboard
  --print(-p)             # print the generated password to the terminal
  --force(-f)             # open secret for editing after generating a password
  --symbols(-s)           # use symbols in the password
  --generator(-g): string # choose a password generator, default: cryptic
  --strict                # Require strict character class rules
  --force-regen(-t)       # Force full re-generation.
  --sep: string           # word separator for generated passwords
  --lang: string          # language to generate password form. currently only en
  --help(-h)              # show help
]

export extern "gopass edit" [
  secret?: string@"nu-completion gopass secrets"
  --editor(-e)   # use this editor binary
  --create(-c)   # create a new secret if none found
  --help(-h)     # show help
]

export extern "gopass delete" [
  secret?: string@"nu-completion gopass folders secrets"
  --recursive(-r)  # Recursive delete files and folders
  --force(-f)      # Force to delete the secret
  --help(-h)       # show help
]

export extern "gopass create" [
  sercet?: string@"nu-completion gopass folders secrets"
  --store(-s)     # which store to use
  --force(-f)     # force path selection
  --help(-h)      # show help
]

export extern "gopass config" [
  --store: string # set options to a specific store
  --help(-h)      # show help
]

def "nu-completion gopass completion" [] {
  ^gopass completion --help
  | lines --skip-empty
  | skip while { |line| (not ( $line | str starts-with "COMMANDS") ) }
  | take while { |line| (not ($line | str starts-with "OPTIONS"))}
  | where { str starts-with "  " }
  | str trim
  | parse --regex '(?P<value>[^,\s]+).*\s{2,}(?P<description>.+)'
}
export extern "gopass completion" [
  subcommand?: string@"nu-completion gopass completion"
  --help(-h)         # show help
]

export extern "gopass clone" [
  --path: string                                        # path to clone the repo to
  --crypto: string@"nu-completion gopass crypto type"   # select crypto backend
  --storage: string@"nu-completion gopass storage type" # select storage backend
  --check-keys                                          # check for valid decryption keys.
  --help(-h)                                            # show help
]

export extern "gopass cat" [
  secret?: string@"nu-completion gopass secrets"
  --help(-h)    # show help
]

def "nu-completion gopass format" [] {
  ["txt" "csv" "html"]
}

export extern "gopass audit" [
  --format: string@"nu-completion gopass format"          # output format, text csv, html
  --output-file(-o): string                               # output filename, Used for csv and html
  --template: string                                      # HTML templete. If not set use the built-in default.
  --full                                                  # print full details of all findings.
  --summary                                               # print a summary of the audit results.
  --help(-h)                                              # show help
]
