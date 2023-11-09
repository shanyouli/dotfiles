{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.macos.iina;
  homeDir = config.my.hm.dir;
  bbdown-cmd = pkgs.writeScriptBin "bbdown" ''
    #!${pkgs.stdenv.shell}

    _dir=${config.my.hm.cacheHome}/bbdown
    if [[ ! -d $_dir ]]; then
      mkdir -p $_dir
    fi
    if [[ ! -f $_dir/bbdown ]]; then
      cp -rv ${pkgs.bbdown}/bin/bbdown $_dir/bbdown
    fi
    exec -a "$0" "$_dir/bbdown"  "$@"
  '';
in {
  options.my.modules.macos.iina = {
    enable = mkBoolOpt false;
    isStream = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    my.modules.mpv.enable = true;
    my.user.packages = with pkgs; [
      iina-app
      (mkIf cfg.isStream iinaplus-app)
      seam
      bbdown-cmd
      zy-player-app
    ];
    # 视频压缩工具, 使用 ffmpeg 取代
    # homebrew.casks = ["handbrake"];
    macos.userScript.setingIinaApp = {
      enable = cfg.isStream;
      desc = "使用iinaplus时，将iina链接到/Applications";
      level = 100;
      text = ''$DRY_RUN_CMD ln -sf ${homeDir}/Applications/Myapps/IINA.app /Applications/ '';
    };
  };
}
