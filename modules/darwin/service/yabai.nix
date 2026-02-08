# NOTE：yabai 在最新的操作系统上会存在一些问题，
#  如果你一直追求最新的系统，我建议你是用最新 commit 编译的 yabai，
#  但是由于 yabai arm64 的编译在nix 上存在问题，@see: https://github.com/NixOS/nixpkgs/pull/445113
#  一直折中方法使用 brew 管理它。
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
  cfg = config.modules.service.yabai;
  cfgBinPath = if (cfg.package == null) then config.homebrew.brewPrefix else "${cfg.package}/bin";
in
{
  options.modules.service.yabai = {
    enable = mkBoolOpt false;
    border.enable = mkBoolOpt cfg.enable;
    package = mkPackageOption pkgs.unstable "yabai" {
      nullable = true;
      extraDescription = "Set modules.services.yabai.package to null on platforms where yabai is not available or marked broken";
    };
    startup.enable = mkBoolOpt cfg.enable;
    keep.enable = mkBoolOpt cfg.enable;
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.package != null) {
      # The scripting addition needs root access to load, which we want to do automatically when logging in.
      # Disable the password requirement for it so that a service can do so without user interaction.
      environment.etc."sudoers.d/yabai-load-sa".source = sudoNotPass "${cfg.package}/bin/yabai --load-sa";
      environment.systemPackages = [ cfg.package ];
    })
    (mkIf (cfg.package == null) {
      homebrew.brews = [
        {
          name = "shanyouli/tap/yabai";
          args = [ "head" ];
        }
      ];
      system.activationScripts.postAsctivation.text = ''
        if [ -f "${config.homebrew.brewPrefix}/yabai" ]; then
          echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 ${config.homebrew.brewPrefix}/yabai | cut -d " " -f 1) ${config.homebrew.brewPrefix}/yabai --load-sa" | tee /etc/sudoers.d/yabai
        fi
      '';
    })
    {
      user.packages = [
        pkgs.darwinapps.yabai-zsh-completions
      ]
      ++ lib.optionals cfg.border.enable [ pkgs.darwinapps.borders ];
      home.configFile."yabai" = {
        source = "${my.dotfiles.config}/yabai";
        recursive = true;
      };

      # https://github.com/LnL7/nix-darwin/blob/b8c286c82c6b47826a6c0377e7017052ad91353c/modules/services/yabai/default.nix#L79
      launchd.user.agents.yabai = {
        serviceConfig = {
          ProgramArguments = [
            "${cfgBinPath}/yabai"
            "--config"
            "${config.home.configDir}/yabai/yabairc"
          ];
          KeepAlive = cfg.keep.enable;
          RunAtLoad = cfg.startup.enable;
          EnvironmentVariables.PATH = "${cfgBinPath}:${config.modules.service.path}";
        };
      };

      # @see https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection
      # yabai 使用需要 nvram 配置
      system.nvram.variables.boot-args = "-arm64e_preview_abi";

      # hammerspoon 配置
      modules.macos.hammerspoon.cmd.yabaiCmd = "${cfgBinPath}/yabai";
    }
  ]);
}
