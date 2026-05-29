use utils.nu [assert-brew]

# Print export statements.
export def main [] {
    assert-brew
    let res = (^brew shellenv
        | lines
        | parse 'export {key}="{value}";'
        | update value { |r|
            $r.value | str replace '\$\{.+\}' '' --regex | str replace ':$' '' --regex
        })

    mut env_vars = {}
    for v in $res {
        if ($v.key != 'PATH') {
            $env_vars = ($env_vars | insert $v.key $v.value)
        }
    }

    return $env_vars
}
