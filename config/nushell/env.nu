#!/usr/bin/env nu

# 文件导入源
const SOURCE_PATH = ($nu.default-config-dir | path join "sources")
const EMPTY_FILE = ($SOURCE_PATH | path join "empty")
if (not ($SOURCE_PATH | path exists)) {
  mkdir $SOURCE_PATH
}

$env.NU_LIB_DIRS = [
  ($nu.config-path | path dirname | path join 'scripts')
  ($nu.config-path | path dirname | path join 'completions')
  $SOURCE_PATH
]

source (if (($SOURCE_PATH | path join "env") | path expand | path exists) { "env" } else { $EMPTY_FILE })

# Filter paths starting with $env.ZPFX parent directory
def zpfx-filter-fn [s: string]: list<any> -> bool {
  if ($env | get -o ZPFX | is-empty) {
    true
  } else {
    let zpfx_dirname = ($env.ZPFX | path dirname)
    (not ( $s | str starts-with $zpfx_dirname))
  }
}

# filter paths starting with /nix/store as PATH
def nix-store-filter-fn [s: string]: list<any> -> any {
  if ($env | get -o IN_NIX_SHELL | is-empty) {
    (not ( $s | str starts-with "/nix/store"))
  } else {
    true
  }
}

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s|
            $s | split row (char esep)
               | path expand --no-symlink
               | uniq
               | where  (zpfx-filter-fn $it)
               | where (nix-store-filter-fn $it)
        }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s|
            $s | split row (char esep)
               | uniqe
               | path expand --no-symlink
               | where  (zpfx-filter-fn $it)
               | where (nix-store-filter-fn $it)
        }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}
hide zpfx-filter-fn
hide nix-store-filter-fn
