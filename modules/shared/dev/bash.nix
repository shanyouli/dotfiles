{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.dev.bash;
in {
  options.modules.dev.bash = {
    enable = mkEnableOption "Whether to develop bash language";
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs.stable; [
      pkgs.unstable.nodePackages.bash-language-server
      shfmt
      shellcheck
    ];
  };
}
