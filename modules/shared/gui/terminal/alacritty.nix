{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.gui.terminal;
  cfg = cfp.alacritty;
  cfgPkg =
    let
      package = pkgs.alacritty;
    in
    if pkgs.stdenvNoCC.isLinux then
      package
    else
      pkgs.symlinkJoin {
        name = "my-alacritty-${package.version}";
        paths = [ package ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          # FIX macos Alacritty GUI error
          rm -rf "$out/Applications/Alacritty.app/Contents/MacOS"
          mkdir -p "$out/Applications/Alacritty.app/Contents/MacOS"
          makeWrapper "${package}/bin/alacritty" "$out/Applications/Alacritty.app/Contents/MacOS/alacritty"
        '';
      };
in
{
  options.modules.gui.terminal.alacritty = {
    enable = mkEnableOption "Whether to use alacritty";
  };
  config = mkIf cfg.enable {
    home.packages = [ cfgPkg ];
    home.configFile = {
      "alacritty" = {
        source = "${my.dotfiles.config}/alacritty";
        recursive = true;
      };
      # TODO: 更多可选配置
    };
  };
}
