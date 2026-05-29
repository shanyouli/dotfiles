const base = (path self | path dirname | path dirname)

def scan-dir [dir: string, rel: string] {
    let path = $"($base)/($dir)"
    if not ($path | path exists) { return [] }
    
    ls $path | each { |e|
        let name = $e.name | path basename
        if $e.type == "dir" {
            $"export use ./($dir)/($name)"
        } else if ($name | str ends-with ".nu") {
            let stem = ($name | str replace ".nu" "")
            $"export use ./($dir)/($name)"
        } else {
            null
        }
    }
}

let cmd_lines = (scan-dir "cmds" "./cmds")
let plugin_lines = (scan-dir "plugins" "./plugins")

let all_lines = ($cmd_lines | append $plugin_lines | where $it != null)

$all_lines | str join (char nl) | save -f $"($base)/generated.nu"
