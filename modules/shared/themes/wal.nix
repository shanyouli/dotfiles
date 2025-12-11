# see https://github.com/eylles/pywal16/wiki/Customization#pywal-extras
# pywal16 是一个非常使用的主题管理工具，它基于 Xresources 配色管理。
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
  cfp = config.modules.themes;
  cfg = cfp.wal;
in
{
  options.modules.themes.wal = {
    enable = mkEnableOption "Whether to use pywal16";
    package = mkPackageOption pkgs.unstable "pywal16" { };
    dark = mkOpt' types.str "catppuccin-frappe" "default dark";
    light = mkOpt' types.str "catppuccin-latte" "default light theme";
  };
  config = mkIf cfg.enable {
    modules = {
      # kitty 配置
      gui.terminal.kitty.settings = "include ~/.cache/wal/colors-kitty.conf\n";
      shell.zsh.prevInit = mkOrder 100 "reload-color() { _source $XDG_CACHE_HOME/wal/colors.sh; }; reload-color\n";
    };
    home = {
      packages = [ cfg.package ];
      configFile = {
        "wal/colorschemes" = {
          source = "${dotfiles.config}/wal/themes";
          recursive = true;
        };
      };
    };
    my.user.init.setTheme =
      optionalString (cfp.use == "dark") ''
        log debug $"Apply ${cfg.dark} theme"
        ${cfg.package}/bin/wal --theme ${cfg.dark} -q
      ''
      + optionalString (cfp.use == "light") ''
        log debug $"Apply ${cfg.light} theme"
        ${cfg.package}/bin/wal --theme ${cfg.light} -q -l
      ''
      + optionalString (cfp.use == "auto") ''
        let is_Dark = (osascript -e "tell application \"System Events\" to tell appearance preferences to return dark mode")
        if ($is_Dark == "false") {
          log debug $"Apply ${cfg.light} theme"
          ${cfg.package}/bin/wal --theme ${cfg.light} -q -l
        } else {
          log debug $"Apply ${cfg.dark} theme"
          ${cfg.package}/bin/wal --theme ${cfg.dark} -q
        }
      '';
  };
}
