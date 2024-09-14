nixify() {
    if [[ ! -e ./.envrc ]]; then
        cat >.envrc <<EOF
# To add more files to be checked use watch_file like this
watch_file \$(find . -name "*.nix" -printf '"%p" ')
# 缓存 direnv 信息，更快进入文件
type nix_direnv_manual_reload >/dev/null 2>&1 && nix_direnv_manual_reload
use nix
EOF
        direnv allow
    fi
    if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
        cat >default.nix <<'EOF'
with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    bashInteractive
  ];
}
EOF
        ${EDITOR:-vim} default.nix
    fi
}

flakify() {
    if [ ! -e flake.nix ]; then
        nix flake new -t github:nix-community/nix-direnv .
    elif [ ! -e .envrc ]; then
        cat >.envrc <<EOF
# To add more files to be checked use watch_file like this
watch_file \$(find . -name "*.nix" -printf '"%p" ')
# 缓存 direnv 信息，更快进入文件
type nix_direnv_manual_reload >/dev/null 2>&1 && nix_direnv_manual_reload
use flake
EOF
        direnv allow
    fi
    ${EDITOR:-vim} flake.nix
}
