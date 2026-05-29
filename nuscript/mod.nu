use std log
export use generated.nu *

def get-plugin-list [base: string] {
    let cmds = (ls $"($base)/cmds" | each { |e| $e.name | path basename | str replace ".nu" "" })
    let plugins = (ls $"($base)/plugins" | each { |e| $e.name | path basename | str replace ".nu" "" })
    ($cmds | append $plugins | uniq | sort)
}

def show-help [base: string] {
    let all = get-plugin-list $base
    print "m - Nushell plugin framework"
    print ""
    print "Usage:"
    print "  m <command> [args]"
    print ""
    print "Available commands:"
    $all | each { |p| print $"  ($p)" }
}

export def --wrapped main [...args] {
    const base = (path self | path dirname)
    if ($args | length) == 0 or ($args.0 | str starts-with "-") {
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
