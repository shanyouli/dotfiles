default:
    @just --list

set positional-arguments := true

@src pkg:
    echo "update src: $1"
    nvfetcher  -k ~/.config/nvfetcher.toml  -f "^$1$"  -j 1
