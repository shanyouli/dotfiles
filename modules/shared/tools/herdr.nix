# 管理 herdr 配置与服务开关
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
  cfg = config.modules.tools.herdr;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.modules.tools.herdr = {
    enable = mkBoolOpt' false "是否启用 herdr。";
    package = mkOpt' types.package pkgs.unstable.herdr "使用的 herdr 软件包。";
    settings = mkOpt' tomlFormat.type { } "生成 herdr/config.toml 的配置。";
    service = {
      enable = mkBoolOpt' cfg.enable "是否启用 herdr 后台服务。";
      startup = mkBoolOpt' false "是否在登录时自动启动 herdr 服务。";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.configFile."herdr/config.toml".source = tomlFormat.generate "herdr-config.toml" cfg.settings;
    env.HERDR_CONFIG_PATH = "${config.home.configDir}/herdr/config.toml";

    modules.tools.herdr.settings = {
      onboarding = mkDefault false;
      theme = {
        name = mkDefault "terminal";
        auto_switch = mkDefault false;
      };
      terminal = {
        default_shell = mkDefault config.modules.shell.default;
        kitty_graphics = mkDefault true;
      };
      ui = {
        agent_panel_sort = mkDefault "spaces";
        show_agent_labels_on_pane_borders = mkDefault true;
        toast.delivery = mkDefault "system";
      };
      experimental.pane_history = mkDefault false;
      update = {
        channel = mkDefault "stable";
        version_check = mkDefault false;
        manifest_check = mkDefault false;
      };
      keys.prefix = mkDefault "ctrl+c";
      keys.switch_tab = mkDefault [
        "prefix+1..9"
        "alt+1..9"
      ];
    };
  };
}
