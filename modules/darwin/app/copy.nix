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
    home.initExtra = let
      apps = pkgs.buildEnv {
        name = "my-manager-applications";
        paths =
          config.user.packages
          ++ config.home-manager.users.${config.user.name}.home.packages
          ++ config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
      syncbin =
        if config.modules.rsync.enable
        then getExe config.modules.rsync.package
        else getexe pkgs.rsync;
      runCmd =
        if cfp.copy.tmp.enable
        then ''
          let rsyncArgs = ["--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--compress" "--ignore-existing"]
          let appBackDir = (mktemp -d -t apps.XXX)
          print $"sync (ansi green_bold)($appSource)(ansi reset) to (ansi yellow)($workdir)(ansi reset)"
          ${syncbin} ...$rsyncArgs $"($appSource)/" $"($workdir)/"
          let removeApps = diff $"($appSource)/" $"($workdir)/" | grep $"Only in ($workdir)" | lines | each {|x| $x | str replace $"Only in ($workdir): " ""}
          chmod +w $workdir
          for i in $removeApps {
            let app = ($workdir | path join $i)
            chmod -R +x $app
            print $"move old ($app) to ($appBackDir)..."
            mv -pf $app $appBackDir
          }
        ''
        else ''
          let rsyncArgs = ["--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--delete"]
          print $"sync (ansi green_bold)($appSource)(ansi reset) to (ansi yellow)($workdir)(ansi reset)"
          ${syncbin} ...$rsyncArgs $"($appSource)/" $"($workdir)/"
        '';
    in
      mkMerge [
        ''
          print $"settings up (ansi blue_bold)${cfp.path}(ansi reset)."
          let workdir = ("${cfp.path}" | path expand)
          let appSource = ("${apps}/Applications" | path expand)
          mkdir $workdir
          ${runCmd}
        ''
        (mkAfter (optionalString cfp.copy.tmp.enable ''
          if (not ($removeApps | is-empty)) {
            print $"If you want to deleting all the data about remove apps."
            print $"Please run (ansi yellow_bold)cd ($appBackDir)(ansi reset)."
            print $"Open Appclean.app. delete (ansi red)($removeApps | each {|x| $x | str replace ".app" ""} | str join ' ')(ansi reset)"
          }
        ''))
      ];
  };
}
