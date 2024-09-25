{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfm = config.modules;
  cfg = cfm.dev.bash;
in {
  options.modules.dev.bash = {
    enable = mkEnableOption "Whether to develop bash language";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodePackages.bash-language-server
      shfmt
      shellcheck
    ];
  };
}
