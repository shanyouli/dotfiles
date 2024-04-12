# list all just recipes
default:
    @just --list

# nvfetcher update package src
@src PKG:
    echo "update src: {{ PKG }}"
    nvfetcher  -k ~/.config/nvfetcher.toml  -f "^{{ PKG }}$"  -j 1
