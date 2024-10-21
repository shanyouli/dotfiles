# list all just recipes
default:
    @just --list

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

[group('home-maanger')]
home-build:
    nix run -v --experimental-features "nix-command flakes" --extra-substituters https://shanyouli.cachix.org --impure github:nix-community/home-manager --no-write-lock-file -- build --flake .#test -b backup --show-trace

[group("shell")]
nu-test:
    rsync -avz --copy-links --chmod=D2755,F744 config/nushell ${HOME}/.config/nushell

[group("shell")]
nu-clean:
    rm -rf "$HOME/.config/nushell"
