# 配置参考 https://zenn.dev/massa/articles/ghostty-usage#macos
#          https://ghostty.org/docs
#          https://ghostty.org/docs/config/reference#mouse-hide-while-typing
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
          macos-option-as-alt = true;
          quit-after-last-window-closed = false; # 默认关闭最后一个窗口后退出应用
          # macos-titlebar-style = tabs;
          # keybind = [

          #   "super+c=copy_to_clipboard"
          #   "super+v="
          #   "super+a="
          # ];
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
          copy-on-select = true; # 选择即复制, clipboard
          clipboard-read = "allow";
          clipboard-write = "allow";

          # 主题配置"
          theme = "light:Rose Pine Dawn,dark:Rose Pine";
          # 启动默认大小, 更具体大小推荐遵从窗口管理工具
          window-height = 33;
          window-width = 120;
          # shell 交互启动
          shell-integration-features = "cursor,sudo,ssh-terminfo,ssh-env";
          mouse-hide-while-typing = true;
          quick-terminal-size = "48%,70%"; # quick 窗口大小，macos 似乎不生效。

          keybind = [
            "global:cmd+enter=toggle_quick_terminal"
            # new window panes
            "ctrl+d>s=new_split:down"
            "ctrl+d>v=new_split:right"
            "ctrl+d>d=close_window"

            # moving panes
            "shift+arrow_right=goto_split:right"
            "shift+arrow_left=goto_split:left"
            "shift+arrow_up=goto_split:up"
            "shift+arrow_down=goto_split:down"

            # 让 当前split最大化
            "ctrl+d>z=toggle_split_zoom"

            # tab 操作
            "ctrl+d>t=new_tab"
            "ctrl+d>n=next_tab"
            "ctrl+d>p=previous_tab"
            "ctrl+d>c=close_tab"

            # 刷新配置
            "f5=reload_config"

            # 字体关
            "ctrl+equal=increase_font_size:1.1"
            "ctrl+-=decrease_font_size:1.1"
            "ctrl+0=reset_font_size"

            # 复制网页
            "ctrl+d>u=copy_url_to_clipboard"
          ];
        }
      ];
      # clearDefaultKeybinds = true;
    };
  };
}
