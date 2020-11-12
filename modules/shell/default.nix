{ config, lib, pkgs, ... }:

{
  imports = [
    ./aria2.nix
    ./direnv.nix
    ./git.nix
    ./gnupg.nix
    ./ncmpcpp.nix
    ./pass.nix
    ./ranger.nix
    ./tmux.nix
    ./weechat.nix
    ./zsh.nix
    ./trash.nix
  ];
}
