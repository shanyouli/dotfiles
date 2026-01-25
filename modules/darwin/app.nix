# 更多信息 see@https://github.com/LnL7/nix-darwin/issues/214#issuecomment-2050027696
# see @https://github.com/nix-darwin/nix-darwin/raw/master/modules/system/applications.nix
# 使用 nix-darwin 默认方式。
{
  lib,
  config,
  my,
  pkgs,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.app;
in
{
  options.modules.macos.app = {
    name = mkOpt' types.str "Myapps" "存放使用 nix 安装的 gui 程序目录名";
    user.enable = mkBoolOpt true; # 默认在家目录的 Applications/${cfg.name} 目录下
    temp.enable = mkEnableOption "Whether use temp.";
    path = mkOption {
      description = "将所有使用 nix 安装的文件存放在一个目录中.";
      type = types.path;
      visible = false;
      readOnly = true;
    };
    linkDir = mkPkgReadOpt "将所有gui程序link一个路径。";
  };
  config = {
    modules = {
      macos.app = {
        path =
          if cfg.user.enable then "${homedir}/Applications/${cfg.name}" else "/Applications/${cfg.name}";
        linkDir = pkgs.buildEnv {
          name = "my-manager-applications";
          paths =
            config.user.packages
            ++ config.home-manager.users.${config.user.name}.home.packages
            ++ config.environment.systemPackages;
          pathsToLink = [ "/Applications" ];
        };
      };
      shell.aliases.emacs = optionalString config.modules.app.editor.emacs.enable "${config.modules.macos.app.path}/Emacs.app/Contents/MacOS/Emacs";
    };
    my = {
      system.init.removeNixApps = ''
        if ("/Applications/Nix Apps" | path exists) {
          ^rm -rf "/Applications/Nix Apps"
        }
      '';
      user.init = {
        removeHomeManagerApps = {
          desc = "Remove Home Manager apps generation link.";
          text = ''
            let homeManagerApps = ($env.HOME | path join "Applications" "Home Manager apps")
            if (($homeManagerApps | path type) == "symlink") {
              rm -rf $homeManagerApps
            }
          '';
        };
        LinkAppsPath =
          let
            syncbin =
              if config.modules.rsync.enable then getExe config.modules.rsync.package else getexe pkgs.rsync;
            runCmd =
              if cfg.temp.enable then
                ''
                  let rsyncArgs = ["--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--compress" "--delete" "--no-group" "--no-owner"]
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
              else
                ''
                  let rsyncArgs = ["--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--delete" "--no-group" "--no-owner"]
                  log debug $"sync ($appSource) to ($workdir)"
                  ${syncbin} ...$rsyncArgs $"($appSource)/" $"($workdir)/"
                '';
          in
          {
            text = ''
              let workdir = ("${cfg.path}" | path expand)
              let appSource = ("${cfg.linkDir}/Applications" | path expand)
              mkdir $workdir
              ${runCmd}
            '';
            desc = "Settings up ${cfg.path}";
          };
        extra = optionalString cfg.temp.enable ''
          if (not ($removeApps | is-empty)) {
            log debug $"If you want to deleting all the data about remove apps."
            log debug $"Please run cd ($appBackDir)."
            log debug $"Open Appclean.app. delete ($removeApps | each {|x| $x | str replace ".app" ""} | str join ' ')"
          }
        '';
      };
    };

  };
}
