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
  cfp = config.modules.gui.terminal;
  cfg = cfp.ghostty;
in
{
  options.modules.gui.terminal.ghostty = {
    enable = mkEnableOption "Whether use ghostty.";
    package = mkPackageOption pkgs (
      if pkgs.stdenvNoCC.hostPlatform.isLinux then "ghostty" else "ghostty-bin"
    ) { };
  };
  config = {
    home.programs.ghostty = {
      inherit (cfg) enable;
      inherit (cfg) package;
      settings = mkMerge [
        (mkIf pkgs.stdenvNoCC.hostPlatform.isLinux {
          quit-after-last-window-closed = false; # 默认关闭最后一个窗口后退出应用
        })
        (mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin {
          macos-titlebar-style = "hidden";
          macos-window-shadow = false;
          quit-after-last-window-closed = true; # 默认关闭最后一个窗口后退出应用
        })
        {
          font-family = config.modules.gui.terminal.font.family;
          font-size = config.modules.gui.terminal.font.size;
          # 参考自己的 kitty 配置
          adjust-cell-height = "10%";
          adjust-underline-position = "10%";
          adjust-underline-thickness = "10%";
          # window 填充相关配置
          window-padding-balance = true;
          window-padding-x = 0;
          window-padding-y = 0;
          window-padding-color = "extend";
          # 工作目录是否继承
          window-inherit-working-directory = true;
          window-theme = "auto"; # system, light, dark, ghostty, auto; 窗口主题
          # 关闭相关选项
          confirm-close-surface = false; # 退出后不要出现确认弹窗

          auto-update = "off"; # 关闭自动更新, check, download,
          copy-on-select = true; # 选择即复制

          # 主题配置"
          theme = "light:Rose Pine Dawn,dark:Rose Pine";
          # 启动默认大小, 更具体大小推荐遵从窗口管理工具
          window-height = 33;
          window-width = 120;
        }
      ];
    };
  };
}
