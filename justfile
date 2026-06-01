# just is a command runner, Justfile is similar to Makefile, but simpler.

set shell := ["nu", "-c"]

utils_nu := absolute_path("utils.nu")

# List all just recipes.
default:
    @just --list

# Temporarily disable skip-worktree for root flake files.
_root-flake-enable target="auto":
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    root-flake-enable {{ target }}

# Re-enable skip-worktree for root flake files.
_root-flake-disable:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    root-flake-disable

# Run an arbitrary nix command against the current root flake.
[positional-arguments]
@nix *args='':
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    run-nix ...$args

# Run CI-only commands that keep root skip-worktree disabled.
[positional-arguments]
ci subcmd='check' *args='':
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    match "{{ subcmd }}" {
        "update" => { ci-update-flake-inputs }
        "check" => { ci-flake-check }
        _ => { error make { msg: "usage: just ci [update|check]" } }
    }

# Link the root flake to one explicit target.
[group('nix')]
init target="auto":
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    init {{ target }}

# Restore placeholder root flake files.
[group('nix')]
reset-flake-root:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    reset-flake-root

# Update nvfetcher source metadata for one package.
[group('nix')]
@src pkg:
    print $"update src: ({{ pkg }})"
    nvfetcher -k ~/.config/nvfetcher.toml -f "^{{ pkg }}$" -j 1

# Copy the Neovim config into ~/.config for manual testing.
[group('neovim')]
nvim-test:
    rsync -avz --copy-links --chmod=D2755,F744 config/nvim/ $"($env.HOME)/.config/nvim/" --exclude="nix.lua"

# Remove the copied Neovim config from ~/.config.
[group('neovim')]
nvim-clean:
    rm -rf $"($env.HOME)/.config/nvim"

# Copy the Nushell config into ~/.config for manual testing.
[group('shell')]
nu-test:
    rsync -avz --copy-links --chmod=D2755,F744 config/nushell $"($env.HOME)/.config/nushell"

# Remove the copied Nushell config from ~/.config.
[group('shell')]
nu-clean:
    rm -rf $"($env.HOME)/.config/nushell"

# Build the test Home Manager configuration.
[group('home-manager')]
home-build:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    run-build-ci test --type home

# Build the current OS host from the root flake.
[group('os')]
build:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    run-build-ci build

# Switch the current OS host from the root flake.
[group('os')]
switch:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    run-build-ci switch

# Build the current Home Manager host from the root flake.
[group('os')]
home:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    run-build-ci build --type home

# Switch a NixOS configuration by host name.
[group('os')]
nixos-switch host mode="default":
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    nixos-switch "{{ host }}" "{{ mode }}"

# Build a Darwin configuration by host name.
[group('os')]
darwin-build host mode="default":
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    darwin-build "{{ host }}" "{{ mode }}"

# Switch a Darwin configuration by host name.
[group('os')]
darwin-switch host mode="default":
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    darwin-switch "{{ host }}" "{{ mode }}"

# Roll back the last Darwin generation.
[group('os')]
darwin-rollback:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    darwin-rollback

# Switch a Home Manager configuration by host name.
[group('home-manager')]
home-switch host:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    home-switch "{{ host }}"

# Run local flake checks without writing lock files.
[group('nix')]
check:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    run-flake-check

# Build the test host for the current root target or a selected type.
[group('nix')]
test type="":
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    if "{{ type }}" == "" {
        run-build-ci test
    } else {
        run-build-ci test --type "{{ type }}"
    }

# Update the current root flake following the normal and stable input rules.
[group('nix')]
update:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    update-root-flake

# Update selected root-flake inputs, or all root inputs when passed `all`.
[group('nix')]
update-inputs +inputs:
    #!/usr/bin/env nu
    use {{ utils_nu }} *
    update-root-inputs ...$inputs
