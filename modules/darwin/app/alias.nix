{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.macos.app;
in {
  config = mkIf (cfp.way == "alias") {
    home.initExtra = let
      apps = pkgs.buildEnv {
        name = "my-manager-applications";
        paths =
          config.user.packages
          ++ config.home-manager.users.${config.user.name}.home.packages
          ++ config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
      bin = getExe pkgs.mkalias;
    in ''
      print $"settings up (ansi blue_bold)${cfp.path}(ansi reset)."
      let workdir = ("${cfp.path}" | path expand)
      let appSource = ("${apps}/Applications" | path expand)
      if ($workdir | path exists) {
        chmod -R +w $workdir
        ls $workdir | get name
                    | filter {|x| ($x | path parse | get extension) == "app" }
                    | each {|x| rm -rf $x }
      } else {
        mkdir $workdir
      }
      let basename_apps = ls $"($appSource)" | get name | path basename
      for i in $basename_apps {
        let real_app = $appSource | path join $i |readlink -f $in
        let target = $workdir | path join $i
        print $"Start creating aliases for application (ansi green)($i | path parse | get stem)(ansi reset)"
        ${bin} $real_app $target
      }
    '';
  };
}
