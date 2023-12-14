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
  cfg = cfm.shell.nix-init;
in {
  # nix-init 可以快速构建nix包，支持 pypi，cargo，gomodule
  # @see https://github.com/nix-community/nix-init
  options.modules.shell.nix-init = {
    enable = mkEnableOption "Whether to install nix-init";
  };
  config = mkIf cfg.enable {
    my.user.package = [pkgs.unstable.nix-init];
    my.hm.configFile."nix-init/config.toml".text = ''
      maintainers = [ "${config.my.username}" ]
      nixpkgs = "<nixpkgs>"
    '';
  };
}
