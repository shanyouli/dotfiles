use std/log

export def init-herdr-integrations [herdr: path, targets: list<string>]: nothing -> nothing {
    let status = (^$herdr integration status | complete)
    if $status.exit_code != 0 {
        log warning $"Herdr integration status failed: ($status.stderr | str trim)"
        return
    }

    let statuses = ($status.stdout | str replace --all ' (experimental): ' ': ' | lines)
    for target in $targets {
        if ($statuses | any {|line| $line | str starts-with $"($target): current" }) {
            continue
        }

        let result = (^$herdr integration install $target | complete)
        if $result.exit_code == 0 {
            log info $"Herdr integration ready: ($target)"
        } else {
            log warning $"Herdr integration install failed for ($target): ($result.stderr | str trim)"
        }
    }
}
