# list all just recipes
default:
    @just --list

init target="auto":
    case "{{ target }}" in auto) target=$([ "$(uname -s)" = "Darwin" ] && echo darwin || echo linux) ;; darwin|linux) target="{{ target }}" ;; *) echo "usage: just init [darwin|linux]" >&2; exit 2 ;; esac; flake_root="./flake/$target"; ln -f "$flake_root/flake.nix" ./flake.nix; ln -f "$flake_root/flake.lock" ./flake.lock; echo "linked $flake_root/{flake.nix,flake.lock} -> ./"

reset-flake-root:
    printf '%s\n' 'throw "Please run `just init [darwin|linux]` first."' > flake.nix
    : > flake.lock
    echo "reset flake.nix and flake.lock to default placeholders"

# nvfetcher update package src
@src PKG:
    echo "update src: {{ PKG }}"
    nvfetcher  -k ~/.config/nvfetcher.toml  -f "^{{ PKG }}$"  -j 1

[group('neovim')]
nvim-test:
    rsync -avz --copy-links --chmod=D2755,F744 config/nvim/ ${HOME}/.config/nvim/ --exclude="nix.lua"

[group('neovim')]
nvim-clean:
    rm -rf "$HOME/.config/nvim"

[group('home-manager')]
home-build:
    nix run -v --experimental-features "nix-command flakes" --extra-substituters https://shanyouli.cachix.org --impure github:nix-community/home-manager --no-write-lock-file -- build --flake ".#test" -b backup --show-trace

[group("shell")]
nu-test:
    rsync -avz --copy-links --chmod=D2755,F744 config/nushell ${HOME}/.config/nushell

[group("shell")]
nu-clean:
    rm -rf "$HOME/.config/nushell"

[group("os")]
switch:
    nix run ".#buildci" -- switch

build:
    nix run ".#buildci" -- build

home:
    nix run ".#buildci" -- build --type home
