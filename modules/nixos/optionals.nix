{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; {
  options.modules.nixos = {
  };
  config = mkMerge [
    (mkIf (config.modules.shell.default == "zsh") {
      # only nixos
      users.defaultUserShell = pkgs.zsh;
    })
  ];
}
