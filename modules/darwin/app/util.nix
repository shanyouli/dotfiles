{
  pkgs,
  lib,
  config,
  my,
  inputs,
  ...
}:
with lib;
with my; let
  cfp = config.modules.macos.app;
  cfgPkg = inputs.mac-app-util.packages.${pkgs.stdenv.system}.default;
in {
  config = mkIf (cfp.way == "util") {
    user.packages = [cfgPkg];
    home.initExtra = let
      apps = pkgs.buildEnv {
        name = "my-manager-applications";
        paths =
          config.user.packages
          ++ config.home-manager.users.${config.user.name}.home.packages
          ++ config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
      syncbin = "${cfgPkg}/bin/mac-app-util";
    in ''
      let workdir = ("${cfp.path}" | path expand)
      let appSource = ("${apps}/Applications" | path expand)
      mkdir $workdir
      print $"sync (ansi green_bold)($appSource)(ansi reset) to (ansi yellow)($workdir)(ansi reset)"
      ${syncbin} sync-trampolines $appSource $workdir
    '';
  };
}
