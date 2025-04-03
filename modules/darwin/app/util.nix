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
    my.user.init.UseMacAppUtilSetAPPPath = let
      syncbin = "${cfgPkg}/bin/mac-app-util";
    in ''
      let workdir = ("${cfp.path}" | path expand)
      let appSource = ("${cfp.linkDir}/Applications" | path expand)
      mkdir $workdir
      log debug "sync ($appSource) to ($workdir)"
      ${syncbin} sync-trampolines $appSource $workdir
    '';
  };
}
