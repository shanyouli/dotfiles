{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos.app;
in
{
  config = mkIf (cfp.way == "alias") {
    my.user.init.SetAppPathByAlias =
      let
        bin = getExe pkgs.mkalias;
      in
      ''
        log debug "settings up ${cfp.path}"
        let workdir = ("${cfp.path}" | path expand)
        let appSource = ("${cfp.linkDir}/Applications" | path expand)
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
          log debug $"Start creating aliases for application ($i | path parse | get stem)"
          ${bin} $real_app $target
        }
      '';
  };
}
