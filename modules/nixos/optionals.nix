{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; {
  options.modules.nixos = {
  };
  config = mkMerge [
    (mkIf (config.modules.shell.default == "zsh") {
      # only nixos
      users.defaultUserShell = pkgs.zsh;
    })
  ];
}
