use std/help
export use generated.nu *

def get-plugin-list [base: string] {
    let cmds = (ls $"($base)/cmds" | each { |e| $e.name | path basename | str replace ".nu" "" })
    let plugins = (ls $"($base)/plugins" | each { |e| $e.name | path basename | str replace ".nu" "" })
    ($cmds | append $plugins | uniq | sort)
}

# Print the top-level help: a list of available plugins with their descriptions.
def show-help [base: string] {
    let names = get-plugin-list $base
    print "m - Nushell plugin framework"
    print ""
    print "Usage:"
    print "  m <command> [args]"
    print ""
    print "Available commands:"
    for c in (help commands
              | where name in $names
              | update description {|c| $c.description | lines | first }
              | select name description) {
        print $"  ($c.name | fill -a left -w 12)( $c.description)"
    }
}

# m - Nushell plugin framework entry point.
#
# Dispatch `m <plugin> <command> [args]` to a plugin under `cmds/` or `plugins/`.
# `--help`/`-h` shows the top-level or plugin help via `std help`.
export def --wrapped main [...args] {
    const base = (path self | path dirname)
    # Normalize --wrapped rest args to list<string>. In nushell 0.113 the rest
    # params are list<glob>, which makes string-only commands (str starts-with)
    # fail with nu::shell::only_supports_this_input_type and may expand globs
    # when forwarded to external commands.
    let args = ($args | each { |a| $a | into string })
    if ($args | length) == 0 or ($args.0 in ["--help" "-h"]) {
        show-help $base
        return
    }

    let plugin = $args.0
    let rest = ($args | skip 1)

    # 查找顺序：cmds -> plugins
    mut dir = $"($base)/cmds/($plugin)"
    mut file = $"($base)/cmds/($plugin).nu"

    if not (($dir | path exists) or ($file | path exists)) {
        $dir = $"($base)/plugins/($plugin)"
        $file = $"($base)/plugins/($plugin).nu"
    }

    if not (($dir | path exists) or ($file | path exists)) {
        error make {msg: $"unknown command or plugin: ($plugin)"}
    }

    # 插件级帮助：m <plugin> --help / -h
    if (($rest | length) > 0 and ($rest.0 in ["--help" "-h"])) {
        return ((help $plugin) | ansi strip)
    }

    let is_flag = (($rest | length) > 0 and ($rest.0 | str starts-with "-"))

    if ($dir | path exists) {
        if ($is_flag or ($rest | length) == 0) {
            nu $"($dir)/mod.nu" ...$rest
        } else {
            let cmd = $rest.0
            let args2 = ($rest | skip 1)
            let cmd_file = $"($dir)/($cmd).nu"
            if ($cmd_file | path exists) {
                nu $cmd_file ...$args2
            } else {
                nu $"($dir)/mod.nu" $cmd ...$args2
            }
        }
    } else {
        nu $file ...$rest
    }
}
