#!/usr/bin/env nu
use std/log
# Print a section banner with BEGIN/END markers.
export def --env tip [--end(-e), ...msg] {
    let log_level = log log-level | get INFO
    let log_format = "%ANSI_START%%MSG%%ANSI_STOP%"
    let term_col = term size | get columns
    let msg_str = $msg | str join " "
    if $end {
        let line = $" ($msg_str), END " | fill --alignment c --character "-" --width $term_col
        log custom -a (ansi blue_dimmed) $line $log_format $log_level
    } else {
        let line = $" ($msg_str), BEGIN " | fill --alignment c --character "-" --width $term_col
        log custom -a (ansi blue_bold) $line $log_format $log_level
    }
}
# Print a subsection banner with stronger separators.
export def --env "log t" [--end(-e), ...msg] {
    let log_level = log log-level | get INFO
    let log_format = "%ANSI_START%%MSG%%ANSI_STOP%"
    let term_col = term size | get columns
    let msg_str = $msg | str join " "
    if $end {
        let line = $" ($msg_str), END " | fill --alignment c --character "=" --width $term_col
        log custom -a (ansi blue_dimmed) $line $log_format $log_level
    } else {
        let line = $" ($msg_str), BEGIN " | fill --alignment c --character "=" --width $term_col
        log custom -a (ansi blue_bold) $line $log_format $log_level
    }
}
# Initialize the shared Nushell log style for one command run.
export def --env init-log [name: string] {
    $env.NU_LOG_FORMAT = "%ANSI_START%%LEVEL%: %MSG%%ANSI_STOP%"
    log set-level 10
    tip $"Init ($name)"
    log debug $"The script file path is ($env.CURRENT_FILE)"
}
# Close the shared Nushell log style for one command run.
export def --env end-log [name: string] { tip -e $"Init ($name)" }
# Return the current OS target used by root flake switching.
export def detect-target [] {
    if ((uname | get operating-system | str lowercase) == "darwin") {
        "darwin"
    } else {
        "linux"
    }
}
# Return the normalized architecture used in flake host names.
export def detect-arch [] {
    if ((uname | get machine | str lowercase) == "arm64") {
        "aarch64"
    } else {
        "x86_64"
    }
}
# Resolve the current root flake target from `flake.nix`.
export def current-root-target [] {
    let match = do { ^rg -q "flake\\.darwinConfigurations" flake.nix } | complete
    if $match.exit_code == 0 {
        "darwin"
    } else {
        "linux"
    }
}
# Count how many days remain until the next month begins.
export def days-until-next-month [] {
    let now = date now
    let current_month = ($now | format date "%Y-%m")
    mut cursor = $now
    mut days = 0
    loop {
        $cursor = ($cursor + 1day)
        $days += 1
        if (($cursor | format date "%Y-%m") != $current_month) {
            break
        }
    }
    $days
}
# Decide whether stable inputs should be updated this week.
export def should-update-stable-inputs [] {
    let remaining_days = days-until-next-month
    $remaining_days <= 7
}
# Build the default host name from user, arch and current target.
export def default-host [] {
    let target = detect-target
    let arch = detect-arch
    $"($env.USER)@($arch)-($target)"
}
# Normalize a requested target name.
export def resolve-target [target: string = auto] { match $target {
    "auto" => (detect-target)
    "darwin" => "darwin"
    "linux" => "linux"
    _ => (error make {msg: "usage: target must be one of auto|darwin|linux"})
} }
# Normalize a high-level type to the flake attribute set name.
export def resolve-flake-attr [flake_type?: string] {
    let target = detect-target
    if $flake_type == null {
        if $target == "darwin" {
            "darwinConfigurations"
        } else {
            "nixosConfigurations"
        }
    } else {
        match $flake_type {
            "darwin" => "darwinConfigurations"
            "linux" => "nixosConfigurations"
            "home" => "homeConfigurations"
            _ => (error make {msg: "type must be one of darwin|linux|home"})
        }
    }
}
# Link the root flake files to one explicit target flake directory.
export def --env init [target: string = auto] {
    init-log "just init"
    let resolved = resolve-target $target
    let flake_root = $"./flake/($resolved)"
    log t $"Link root flake for ($resolved)"
    ^ln -f $"($flake_root)/flake.nix" ./flake.nix
    ^ln -f $"($flake_root)/flake.lock" ./flake.lock
    log info $"hard linked ($flake_root)/{flake.nix,flake.lock} -> ./"
    log t -e $"Link root flake for ($resolved)"
    end-log "just init"
}
# Restore placeholder root flake files.
export def --env reset-flake-root [] {
    init-log "just reset-flake-root"
    let placeholder = 'throw "Please run `just init [darwin|linux]` first."'
    log t "Reset root flake placeholders"
    $placeholder | save --force flake.nix
    "" | save --force flake.lock
    log info "reset flake.nix and flake.lock to default placeholders"
    log t -e "Reset root flake placeholders"
    end-log "just reset-flake-root"
}
# Enable tracking for root flake files during a temporary operation.
export def --env root-flake-enable [target: string = auto] {
    init-log "just _root-flake-enable"
    let resolved = resolve-target $target
    init $resolved
    log t $"Enable root flake tracking for ($resolved)"
    ^git update-index --no-skip-worktree flake.nix flake.lock
    log info $"enabled root flake for ($resolved)"
    log t -e $"Enable root flake tracking for ($resolved)"
    end-log "just _root-flake-enable"
}
# Re-apply skip-worktree to root flake files.
export def --env root-flake-disable [] {
    init-log "just _root-flake-disable"
    log t "Disable root flake tracking"
    ^git update-index --skip-worktree flake.nix flake.lock
    log info "disabled root flake tracking"
    log t -e "Disable root flake tracking"
    end-log "just _root-flake-disable"
}
# Open root flake tracking and leave skip-worktree disabled afterwards.
export def --env root-flake-open [target: string = auto] {
    let resolved = resolve-target $target
    init $resolved
    log t $"Open root flake tracking for ($resolved)"
    ^git update-index --no-skip-worktree flake.nix flake.lock
    log info $"opened root flake tracking for ($resolved)"
    log t -e $"Open root flake tracking for ($resolved)"
}
# Run a closure with root flake tracking enabled, then restore skip-worktree.
export def --env with-root-flake [closure: closure, target: string = auto] {
    let resolved = resolve-target $target
    root-flake-enable $resolved
    try {
        do $closure
    } catch {|err|
        root-flake-disable
        error make {
            msg: ($err | to nuon)
        }
    }
    root-flake-disable
}
# Run a closure in CI mode and keep skip-worktree disabled afterwards.
export def --env with-ci-root-flake [closure: closure, target: string = auto] {
    let resolved = resolve-target $target
    log info $"ci mode: leave skip-worktree disabled for ($resolved)"
    root-flake-open $resolved
    do $closure
}
# Run an arbitrary nix command against the current root flake.
export def --env run-nix [...args] {
    init-log "just nix"
    with-root-flake {|| ^nix ...$args }
    end-log "just nix"
}
# Return the current root flake input names from metadata.
export def current-input-names [] {
    ^nix flake metadata --json | from json | get locks.nodes.root.inputs | columns | sort
}
# Return the non-stable root inputs for one target flake.
export def common-update-inputs [target: string] {
    let stable_inputs = stable-update-inputs (resolve-target $target)
    current-input-names | where {|input| $input not-in $stable_inputs }
}
# Return stable update inputs for one target flake.
export def stable-update-inputs [target: string] { match (resolve-target $target) {
    "linux" => ["nixpkgs-stable", "home-manager"]
    "darwin" => ["nixpkgs-stable", "home-manager", "darwin"]
} }
def stable-update-context [] { {
    remaining_days: (days-until-next-month)
    weekday: (date now | format date "%u")
} }
def log-stable-update [] {
    let msg = ["update stable inputs:", "within 7 days of the next month"] | str join " "
    log info $msg
}
def log-skip-stable [] {
    let status = stable-update-context
    let msg = [
        "skip stable inputs;"
        $"weekday=($status.weekday),"
        $"days-until-next-month=($status.remaining_days)"
    ] | str join " "
    log info $msg
}
def resolve-update-inputs [...inputs] {
    if (($inputs | length) == 1 and ($inputs | first) == "all") {
        current-input-names
    } else {
        $inputs
    }
}
# Update the current root flake inputs in-place.
export def update-current-root-inputs [...inputs] {
    if ($inputs | is-empty) {
        log info "update all inputs for current root flake"
        ^nix flake update
    } else {
        log info $"update current root inputs: ($inputs | str join ', ')"
        ^nix flake update ...$inputs
    }
}
# Update the root flake according to the local scheduled rule.
export def --env update-root-flake [] {
    init-log "just update"
    with-root-flake {||
        let target = current-root-target
        update-current-root-inputs ...(common-update-inputs $target)
        if (should-update-stable-inputs) {
            log-stable-update
            update-current-root-inputs ...(stable-update-inputs $target)
        } else {
            log-skip-stable
        }
    }
    end-log "just update"
}
# Update selected inputs for the current root flake.
export def --env update-root-inputs [...inputs] {
    init-log "just update"
    with-root-flake {||
        let actual_inputs = resolve-update-inputs ...$inputs
        update-current-root-inputs ...$actual_inputs
    }
    end-log "just update"
}
# Stage both target flake files that are intended to be versioned.
export def --env stage-flake-input-files [] {
    log t "Stage flake input files"
    let files = [flake/linux/flake.nix, flake/linux/flake.lock, flake/darwin/flake.nix, flake/darwin/flake.lock]
    ^git add ...$files
    log t -e "Stage flake input files"
}
# Stage only target lock files.
export def --env stage-flake-lock-files [] {
    log t "Stage flake lock files"
    ^git add flake/linux/flake.lock flake/darwin/flake.lock
    log t -e "Stage flake lock files"
}
# Return true when the index currently has staged changes.
export def has-staged-changes [] {
    do { ^git diff --cached --quiet } | complete | get exit_code | $in != 0
}
# Commit staged target flake input changes with the standard message.
export def --env commit-flake-input-updates [] {
    if (has-staged-changes) {
        log info "commit flake input updates"
        ^git commit -m "build(deps): update flake inputs"
    } else {
        log info "no flake input changes"
    }
}
# Run the full multi-target CI input update flow.
export def --env ci-update-flake-inputs [] {
    init-log "just ci update"
    with-ci-root-flake {||
        init linux
        update-current-root-inputs ...(common-update-inputs linux)
        init darwin
        update-current-root-inputs ...(common-update-inputs darwin)
        if (should-update-stable-inputs) {
            log-stable-update
            init linux
            update-current-root-inputs ...(stable-update-inputs linux)
            init darwin
            update-current-root-inputs ...(stable-update-inputs darwin)
        } else {
            log-skip-stable
        }
        stage-flake-input-files
        commit-flake-input-updates
    }
    end-log "just ci update"
}
# Run the local flake checks without allowing lock writes.
export def --env run-flake-check [] {
    init-log "just check"
    with-root-flake {|| ^nix flake check --no-write-lock-file --show-trace --impure }
    end-log "just check"
}
# Run CI flake checks and allow lock refreshes.
export def run-flake-check-in-session [] { ^nix flake check --show-trace --impure }
def home-manager-run-base [] { [
    "run"
    "-v"
    "--experimental-features"
    "nix-command flakes"
    "--extra-substituters"
    "https://shanyouli.cachix.org"
    "--impure"
    "github:nix-community/home-manager"
    "--no-write-lock-file"
    "--"
] }
def run-home-manager [action: string, flake_ref: string] {
    let args = (home-manager-run-base) ++ [
        $action
        "--flake"
        $flake_ref
        "-b"
        "backup"
        "--show-trace"
    ]
    ^nix ...$args
}
def os-build-ref [flake_attr: string, host: string] { $".#($flake_attr).($host).config.system.build.toplevel" }
def --wrapped run-nix-build-command [...args] {
    if (which nom | is-empty) {
        ^nix build ...$args
    } else {
        ^nom build ...$args
    }
}
def --wrapped run-nixos-rebuild [...args] { ^./result/sw/bin/nixos-rebuild ...$args }
def --wrapped run-darwin-rebuild [...args] { ^./result/sw/bin/darwin-rebuild ...$args }
# Run CI flake checks, then commit lock updates when they appear.
export def --env ci-flake-check [] {
    init-log "just ci check"
    with-ci-root-flake {||
        run-flake-check-in-session
        stage-flake-lock-files
        if (has-staged-changes) {
            log info "commit flake lock updates from ci check"
            ^git commit -m "build(deps): refresh flake locks after check"
        } else {
            log info "no flake lock changes after ci check"
        }
    }
    end-log "just ci check"
}
# Build or switch OS/home targets using the current root flake.
export def --env build-ci [
    subcmd: string = test
    --type: string
    --host: string
    ...rest
] {
    init-log $"buildCI ($subcmd)"
    let common_options = [--impure, --extra-substituters, "https://shanyouli.cachix.org", --show-trace, -L]
    let flake_attr = resolve-flake-attr $type
    let system_target = detect-target
    let resolved_host = $host | default (default-host)
    log t "Resolve execution context"
    let context_msg = [
        $"system=($system_target),"
        $"host=($resolved_host),"
        $"flakeAttr=($flake_attr)"
    ] | str join " "
    log info $context_msg
    log t -e "Resolve execution context"
    if $subcmd == "test" {
        if $flake_attr == "homeConfigurations" {
            run-home-manager build ".#test"
        } else {
            let platform = $"(detect-arch)-($system_target)"
            let flake_ref = os-build-ref $flake_attr $"test@($platform)"
            let args = [$flake_ref] ++ $common_options ++ $rest
            run-nix-build-command ...$args
        }
        end-log $"buildCI ($subcmd)"
        return
    }
    if $subcmd == "build" {
        if $flake_attr == "homeConfigurations" {
            run-home-manager build $".#($resolved_host)"
        } else {
            let flake_ref = os-build-ref $flake_attr $resolved_host
            let args = [$flake_ref] ++ $common_options ++ $rest
            run-nix-build-command ...$args
        }
        end-log $"buildCI ($subcmd)"
        return
    }
    if $subcmd == "switch" {
        if $flake_attr == "homeConfigurations" {
            run-home-manager switch $".#($resolved_host)"
        } else {
            let flake_ref = os-build-ref $flake_attr $resolved_host
            log info $"build flake ref: ($flake_ref)"
            let build_args = ["-v", "--experimental-features", "nix-command flakes", $flake_ref] ++ $common_options ++ $rest
            run-nix-build-command ...$build_args
            let switch_args = [
                "switch"
                "--flake"
                $".#($resolved_host)"
                "--impure"
            ]
            match $flake_attr {
                "darwinConfigurations" => {
                    run-darwin-rebuild ...$switch_args
                }
                "nixosConfigurations" => {
                    run-nixos-rebuild ...$switch_args
                }
                _ => (error make {
                    msg: $"unsupported flake attr for switch: ($flake_attr)"
                })
            }
        }
        end-log $"buildCI ($subcmd)"
        return
    }
    error make {msg: "subcmd must be one of test|build|switch"}
}
# Run a build/test/switch command with temporary root flake tracking.
export def --env run-build-ci [
    subcmd: string = test
    --type: string
    --host: string
    ...rest
] {
    with-root-flake {|| build-ci $subcmd --type $type --host $host ...$rest }
}
# Switch a NixOS system configuration by host name.
export def nixos-switch [name: string, mode: string = default] {
    print $"nixos-switch '($name)' in '($mode)' mode..."
    if $mode == "debug" {
        let flake_ref = os-build-ref "nixosConfigurations" $name
        run-nix-build-command $flake_ref --show-trace --verbose
        let args = [
            "switch"
            "--flake"
            $".#($name)"
            "--impure"
            "--show-trace"
            "--verbose"
        ]
        run-nixos-rebuild ...$args
    } else {
        run-nixos-rebuild switch --flake $".#($name)" --impure
    }
}
# Build a Darwin system configuration by host name.
export def darwin-build [name: string, mode: string = default] {
    print $"darwin-build '($name)' in '($mode)' mode..."
    let target = $".#darwinConfigurations.($name).system"
    if $mode == "debug" {
        let args = [$target, "--extra-experimental-features", "nix-command flakes", "--show-trace", "--verbose"]
        run-nix-build-command ...$args
    } else {
        let args = [$target, "--extra-experimental-features", "nix-command flakes"]
        run-nix-build-command ...$args
    }
}
# Switch a Darwin system configuration by host name.
export def darwin-switch [name: string, mode: string = default] {
    print $"darwin-switch '($name)' in '($mode)' mode..."
    if $mode == "debug" {
        let args = [
            "switch"
            "--flake"
            $".#($name)"
            "--impure"
            "--show-trace"
            "--verbose"
        ]
        run-darwin-rebuild ...$args
    } else {
        run-darwin-rebuild switch --flake $".#($name)" --impure
    }
}
# Roll back the previously built Darwin generation.
export def darwin-rollback [] { run-darwin-rebuild --rollback }
# Switch a Home Manager configuration by host name.
export def home-switch [name: string] { run-home-manager switch $".#($name)" }
