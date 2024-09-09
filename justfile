# list all just recipes
default:
    @just --list

# nvfetcher update package src
@src PKG:
    echo "update src: {{ PKG }}"
    nvfetcher  -k ~/.config/nvfetcher.toml  -f "^{{ PKG }}$"  -j 1

[group('neovim')]
nvim-test:
    rm -rf "${HOME}/.config/nvim"
    rsync -avz --copy-links --chmod=D2755,F744 config/nvim/ ${HOME}/.config/nvim/

[group('neovim')]
nvim-clean:
    rm -rf "$HOME/.config/nvim"
