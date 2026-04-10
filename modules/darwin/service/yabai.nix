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
  nushellBin =
    if config.modules.shell.nushell.enable then
      "${config.modules.shell.nushell.package}/bin/nu"
    else
      "${pkgs.nushell}/bin/nu";
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
      services.yabai = {
        enable = true;
        inherit (cfg) package;
        config = {
          # 窗口间距设置
          bottom_padding = 5;
          left_padding = 5;
          right_padding = 5;
          top_padding = 5;
          # 调试信息
          debug_output = "off";
          # 自动平衡所有窗口始终占据相同的空间
          auto_balance = "off";
          # 如果禁用自动平衡，此项属性定义的是新窗口占用的空间量。0.5意为旧窗口占用50%
          split_ratio = 0.50;

          mouse_action1 = "move";
          mouse_action2 = "resize";
          # 焦点跟随鼠标 默认off: 关闭  autoraise:自动提升 autofocus: 自动对焦
          focus_follows_mouse = "off";
          # 设置鼠标是否跟随当前活动窗口 默认 off: 关闭 on: 开启
          mouse_follows_focus = "on";
          # 鼠标修饰键 意思就是按着这个键就可以使用鼠标单独修改窗口大小了
          mouse_modifier = "fn";

          # NOTE: 被移除浮动窗口问题在顶部
          # window_topmost=off
          # 修改窗口阴影 on: 打开 off: 关闭 float: 只显示浮动窗口的阴影
          window_shadow = "float";

          # 窗口透明度设置
          window_opacity = "on";
          # 配置活动窗口不透明度
          active_window_opacity = 0.98;
          normal_window_opacity = 0.9;
          window_opacity_duration = 0.0;

          # 在所有显示器上的每个空间顶部添加 0 填充 底部添加 0 填充
          external_bar = "all:0:0";
          # 默认layout
          layout = "bsp";
          window_placement = "second_child";
          window_gap = 4;
        };
        extraConfig = ''
          ${nushellBin} "${config.home.configDir}/yabai/yabairc.nu"
          [[ -f "${config.home.configDir}/yabai/yabairc.extra.nu" ] && {
            ${nushellBin} "${config.home.configDir}/yabai/yabairc.extra.nu"
          }
        '';
      };
    })
    (mkIf (cfg.package == null) {
      homebrew.brews = [
        {
          name = "shanyouli/tap/yabai";
          args = [ "head" ];
        }
      ];
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
      system.activationScripts.postAsctivation.text = ''
        if [ -f "${config.homebrew.brewPrefix}/yabai" ]; then
          echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 ${config.homebrew.brewPrefix}/yabai | cut -d " " -f 1) ${config.homebrew.brewPrefix}/yabai --load-sa" | tee /etc/sudoers.d/yabai
        fi
      '';
      home.configFile."yabai/yabairc".text = ''
        #!/usr/bin/env bash
        # yabai -m config debug_output on
        yabai -m config bottom_padding 5
        yabai -m config left_padding 5
        yabai -m config right_padding 5
        yabai -m config top_padding 5
        yabai -m config auto_balance off
        yabai -m config split_ratio 0.50
        yabai -m config mouse_action1 move
        yabai -m config mouse_action2 resize
        yabai -m config focus_follows_mouse off
        yabai -m config mouse_follows_focus on
        yabai -m config mouse_modifier fn
        yabai -m config window_shadow float
        yabai -m config window_opacity on
        yabai -m config active_window_opacity 0.98
        yabai -m config normal_window_opacity 0.9
        yabai -m config window_opacity_duration 0.0
        yabai -m config external_bar all:0:0
        yabai -m config layout bsp
        yabai -m config window_placement second_child
        yabai -m config window_gap 4
        ${nushellBin} "${config.home.configDir}/yabai/yabairc.nu"
        [[ -f "${config.home.configDir}/yabai/yabairc.extra.nu" ] && {
           ${nushellBin} "${config.home.configDir}/yabai/yabairc.extra.nu"
        }
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

      # @see https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection
      # yabai 使用需要 nvram 配置
      system.nvram.variables.boot-args = "-arm64e_preview_abi";

      # hammerspoon 配置
      modules.macos.hammerspoon.cmd.yabaiCmd = "${cfgBinPath}/yabai";
    }
  ]);
}
