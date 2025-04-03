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
  cfp = config.modules.macos.app;
in {
  options.modules.macos.app.copy.tmp.enable = mkBoolOpt true; # 是否使用临时文件保存待删除的文件.
  config = mkIf (cfp.way == "copy") {
    my.user = {
      init.LinkAppsPath = let
        syncbin =
          if config.modules.rsync.enable
          then getExe config.modules.rsync.package
          else getexe pkgs.rsync;
        runCmd =
          if cfp.copy.tmp.enable
          then ''
            let rsyncArgs = ["--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--compress" "--ignore-existing"]
            let appBackDir = (mktemp -d -t apps.XXX)
            log debug $"sync ($appSource) to ($workdir)"
            ${syncbin} ...$rsyncArgs $"($appSource)/" $"($workdir)/"
            let removeApps = diff $"($appSource)/" $"($workdir)/" | grep $"Only in ($workdir)" | lines | each {|x| $x | str replace $"Only in ($workdir): " ""}
            chmod +w $workdir
            for i in $removeApps {
              let app = ($workdir | path join $i)
              chmod -R +x $app
              log debug $"move old ($app) to ($appBackDir)..."
              mv -pf $app $appBackDir
            }
          ''
          else ''
            let rsyncArgs = ["--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--delete"]
            log debug $"sync ($appSource) to ($workdir)"
            ${syncbin} ...$rsyncArgs $"($appSource)/" $"($workdir)/"
          '';
      in {
        text = ''
          let workdir = ("${cfp.path}" | path expand)
          let appSource = ("${cfp.linkDir}/Applications" | path expand)
          mkdir $workdir
          ${runCmd}
        '';
        desc = "Settings up ${cfp.path}";
      };
      extra = optionalString cfp.copy.tmp.enable ''
        if (not ($removeApps | is-empty)) {
          log debug $"If you want to deleting all the data about remove apps."
          log debug $"Please run cd ($appBackDir)."
          log debug $"Open Appclean.app. delete ($removeApps | each {|x| $x | str replace ".app" ""} | str join ' ')"
        }
      '';
    };
  };
}
