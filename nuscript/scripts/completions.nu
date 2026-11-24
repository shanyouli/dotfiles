# 从 `std help` 的命令信息生成 zsh/bash 补全脚本。
#
# 数据源：`help commands`（命令层级 + flag 签名）。生成物：`completions/_m`（zsh）与
# `completions/m.bash`（bash）。新增插件后重跑本脚本即可覆盖新命令，无需改动本文件。
use std/help
use ../generated.nu *

# 非用户输入的命令（如 command_not_found hook），不出现在补全中。
# 普通插件零配置；仅新增 hook 类命令时在此加一条「插件 命令」。
const EXCLUDE = ["brew not-found"]

# 扫描 cmds/ + plugins/ 得到顶层插件名（与 gen.nu 的导出集合一致）。
def get-plugin-list [base: string] {
    let cmds = (ls $"($base)/cmds" | each {|e| $e.name | path basename | str replace ".nu" "" })
    let plugins = (ls $"($base)/plugins" | each {|e| $e.name | path basename | str replace ".nu" "" })
    ($cmds | append $plugins | uniq | sort)
}

# 把单文件插件的 `cc-switch main list` 归一化为 `cc-switch list`（去掉 `main` 段）。
def normalize-name [name: string] {
    $name | split row " " | where {|seg| $seg != "main"} | str join " "
}

# zsh 补全描述串里的特殊字符转义（`[` `]` 是 _arguments 的描述边界，`'` 会截断字符串）。
def zsh-escape [s: string] {
    $s | str replace -a "[" "\\[" | str replace -a "]" "\\]" | str replace -a "'" "’"
}

# 合并 signatures record 所有 key（any/nothing/...）的参数表。
def get-params [c: record] {
    ($c.signatures | columns | each {|k| $c.signatures | get $k } | flatten)
}

# 提取命令的 flag（named/switch 参数）。
def get-flags [c: record] {
    (get-params $c)
    | where parameter_type in [named switch]
    | each {|p| {
        name: $p.parameter_name,
        short: (if ($p.short_flag | is-empty) { "" } else { $p.short_flag }),
        desc: ($p.description | default ""),
        takes_value: ($p.parameter_type == "named")
    }}
}

# 提取命令的位置参数（positional/rest）。
def get-positional [c: record] {
    (get-params $c)
    | where parameter_type in [positional rest]
    | each {|p| {
        name: ($p.parameter_name | default ""),
        desc: ($p.description | default ""),
        is_rest: ($p.parameter_type == "rest")
    }}
}

# 把命令按路径段插入命令树的 sub 层级（树是嵌套 node：{desc, flags, positional, sub}）。
def insert-path [node: record, parts: list<string>, child: record] {
    if ($parts | length) == 1 {
        $node | upsert sub ($node.sub | upsert $parts.0 $child)
    } else {
        let head = $parts.0
        let rest = ($parts | skip 1)
        let existing = ($node.sub | get -o $head | default {desc: "", flags: [], positional: [], sub: {}})
        let newchild = (insert-path $existing $rest $child)
        $node | upsert sub ($node.sub | upsert $head $newchild)
    }
}

# 从 `help commands` 构建命令树：顶层 m 是一个 node，插件挂在它的 sub 下。
def build-tree [commands: list] {
    mut tree = {desc: "", flags: [], positional: [], sub: {}}
    for c in $commands {
        let parts = (normalize-name $c.name | split row " ")
        let node = {
            desc: ($c.description | default ""),
            flags: (get-flags $c),
            positional: (get-positional $c),
            sub: {}
        }
        $tree = (insert-path $tree $parts $node)
    }
    $tree
}

# 渲染单个 flag 为 zsh `_arguments` 片段。
def render-zsh-flag [f: record] {
    let desc = (zsh-escape $f.desc)
    let long = ("--" + $f.name)
    if ($f.takes_value) {
        if ($f.short | is-empty) {
            ("'" + $long + "[" + $desc + "]:" + $f.name + ":'")
        } else {
            let short = ("-" + $f.short)
            ("'(-" + $f.short + " " + $long + ")'{" + $short + "," + $long + "}'[" + $desc + "]:" + $f.name + ":'")
        }
    } else {
        if ($f.short | is-empty) {
            ("'" + $long + "[" + $desc + "]'")
        } else {
            let short = ("-" + $f.short)
            ("'(-" + $f.short + " " + $long + ")'{" + $short + "," + $long + "}'[" + $desc + "]'")
        }
    }
}

# 渲染位置参数为 zsh `_arguments` 片段（idx 从 1 开始，rest 用 *）。
def render-zsh-positional [p: record, idx: int] {
    let desc = (zsh-escape $p.desc)
    let name = (if ($p.name | is-empty) { "arg" } else { $p.name })
    if ($p.is_rest) {
        ("'*:" + $name + ":" + $desc + "'")
    } else {
        ("'" + ($idx | into string) + ":" + $name + ":" + $desc + "'")
    }
}

# 节点的 flag + 位置参数片段（合并为一个 `_arguments` 参数列表）。
def render-flag-pos [node: record] {
    let flags = ($node.flags | each {|f| render-zsh-flag $f})
    let pos = ($node.positional | enumerate | each {|e| render-zsh-positional $e.item ($e.index + 1)})
    ($flags | append $pos)
}

# 生成单个节点的 zsh 函数：flag 分支 + 子命令分派。
def gen-zsh-func [path: list<string>, node: record] {
    let fname = (if ($path | is-empty) { "_m" } else { "_m_" + ($path | str join "_") })
    let sub_names = ($node.sub | columns | sort)
    let sub_idx = ($path | length) + 2
    let flag_pos = (render-flag-pos $node)

    mut lines = []
    $lines = ($lines | append ($fname + "() {"))
    if ($sub_names | length) > 0 {
        if ($flag_pos | length) > 0 {
            $lines = ($lines | append "  if [[ \$words[CURRENT] == -* ]]; then")
            $lines = ($lines | append "    _arguments \\")
            for x in $flag_pos { $lines = ($lines | append $"      ($x) \\") }
            $lines = ($lines | append "      && return")
            $lines = ($lines | append "  fi")
        }
        $lines = ($lines | append "  local -a subcommands")
        $lines = ($lines | append "  subcommands=(")
        for s in $sub_names {
            let subnode = ($node.sub | get $s)
            $lines = ($lines | append $"    '($s):(zsh-escape $subnode.desc)'")
        }
        $lines = ($lines | append "  )")
        $lines = ($lines | append $"  local sub=\${words[($sub_idx)]}")
        $lines = ($lines | append "  case \$sub in")
        for s in $sub_names {
            $lines = ($lines | append $"    ($s)) _m_($path | append $s | str join "_") ;;")
        }
        $lines = ($lines | append "    *) _describe 'subcommand' subcommands ;;")
        $lines = ($lines | append "  esac")
    } else if ($flag_pos | length) > 0 {
        $lines = ($lines | append "  _arguments \\")
        for x in $flag_pos { $lines = ($lines | append $"      ($x) \\") }
        $lines = ($lines | append "      && return")
    } else {
        $lines = ($lines | append "  _message 'no arguments'")
    }
    $lines = ($lines | append "}")
    $lines
}

# 递归生成整棵树的 zsh 函数。
def gen-zsh-all [path: list<string>, node: record] {
    mut lines = (gen-zsh-func $path $node)
    for s in ($node.sub | columns | sort) {
        let subnode = ($node.sub | get $s)
        $lines = ($lines | append (gen-zsh-all ($path | append $s) $subnode))
    }
    $lines
}

# 生成完整 zsh 补全文件内容。
def gen-zsh [tree: record] {
    mut lines = ["#compdef m", ""]
    $lines = ($lines | append (gen-zsh-all [] $tree))
    $lines = ($lines | append ["", "_m \"\$@\""])
    ($lines | str join "\n")
}

# 节点的 flag 词列表（bash compgen -W 用，长/短 flag 都列）。
def render-bash-flag-words [node: record] {
    mut words = []
    for f in $node.flags {
        $words = ($words | append $"--($f.name)")
        if ($f.short | is-not-empty) {
            $words = ($words | append $"-($f.short)")
        }
    }
    ($words | str join " ")
}

# 生成单个节点的 bash 函数：flag 分支 + 子命令分派。
def gen-bash-func [path: list<string>, node: record] {
    let fname = (if ($path | is-empty) { "_m" } else { "_m_" + ($path | str join "_") })
    let sub_names = ($node.sub | columns | sort)
    let sub_idx = ($path | length) + 1
    let flag_words = (render-bash-flag-words $node)
    let sub_words = ($sub_names | str join " ")

    mut lines = []
    $lines = ($lines | append ($fname + "() {"))
    $lines = ($lines | append "  local cur=\${COMP_WORDS[COMP_CWORD]}")
    if ($sub_names | length) > 0 {
        $lines = ($lines | append $"  local sub=\${COMP_WORDS[($sub_idx)]}")
        $lines = ($lines | append "  case \$sub in")
        for s in $sub_names {
            $lines = ($lines | append $"    ($s)) _m_($path | append $s | str join "_") ;;")
        }
        $lines = ($lines | append "    *)")
        if ($flag_words | is-not-empty) {
            $lines = ($lines | append "      if [[ \$cur == -* ]]; then")
            $lines = ($lines | append ("        COMPREPLY=( \$(compgen -W \"" + $flag_words + "\" -- \$cur) )"))
            $lines = ($lines | append "      else")
            $lines = ($lines | append ("        COMPREPLY=( \$(compgen -W \"" + $sub_words + "\" -- \$cur) )"))
            $lines = ($lines | append "      fi")
        } else {
            $lines = ($lines | append ("      COMPREPLY=( \$(compgen -W \"" + $sub_words + "\" -- \$cur) )"))
        }
        $lines = ($lines | append "      ;;")
        $lines = ($lines | append "  esac")
    } else if ($flag_words | is-not-empty) {
        $lines = ($lines | append ("  COMPREPLY=( \$(compgen -W \"" + $flag_words + "\" -- \$cur) )"))
    } else {
        $lines = ($lines | append "  COMPREPLY=()")
    }
    $lines = ($lines | append "}")
    $lines
}

# 递归生成整棵树的 bash 函数。
def gen-bash-all [path: list<string>, node: record] {
    mut lines = (gen-bash-func $path $node)
    for s in ($node.sub | columns | sort) {
        let subnode = ($node.sub | get $s)
        $lines = ($lines | append (gen-bash-all ($path | append $s) $subnode))
    }
    $lines
}

# 生成完整 bash 补全文件内容。
def gen-bash [tree: record] {
    mut lines = (gen-bash-all [] $tree)
    $lines = ($lines | append ["", "complete -F _m m"])
    ($lines | str join "\n")
}

# 生成 zsh/bash 补全文件到 completions/（--out 指定目录）。
export def main [--out: string = ""] {
    const base = (path self | path dirname | path dirname)
    let outdir = (if ($out | is-empty) { $"($base)/completions" } else { $out })
    mkdir $outdir

    let plugins = (get-plugin-list $base)
    let commands = (help commands
        | where {|c| ($c.name in $plugins) or ($plugins | any {|p| $c.name | str starts-with $"($p) "}) }
        | where {|c| (normalize-name $c.name) not-in $EXCLUDE }
    )
    let tree = (build-tree $commands)

    (gen-zsh $tree) | save -f $"($outdir)/_m"
    (gen-bash $tree) | save -f $"($outdir)/m.bash"
    print $"generated ($outdir)/_m and ($outdir)/m.bash"
}
