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
  cfg = config.modules.shell.multiplexer.herdr;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.modules.shell.multiplexer.herdr = {
    enable = mkBoolOpt' false "是否启用 herdr。";
    package = mkOpt' types.package pkgs.unstable.herdr "使用的 herdr 软件包。";
    settings = mkOpt' tomlFormat.type { } "生成 herdr/config.toml 的配置。";
    integrations = mkOpt' (types.listOf (types.strMatching "[a-z][a-z0-9-]*")) [
      "pi"
      "claude"
      "codex"
    ] "用户激活时初始化的 Herdr Agent 集成；空列表禁用初始化。";
    service = {
      enable = mkBoolOpt' cfg.enable "是否启用 herdr 后台服务。";
      startup = mkBoolOpt' false "是否在登录时自动启动 herdr 服务。";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.configFile."herdr/config.toml".source = tomlFormat.generate "herdr-config.toml" cfg.settings;
    env.HERDR_CONFIG_PATH = "${config.home.configDir}/herdr/config.toml";

    my.user.init.initHerdrIntegrations = {
      enable = cfg.integrations != [ ];
      desc = "初始化 Herdr Agent 集成。";
      text = ''
        # 初始化目标 Agent 的集成，跳过已更新项；失败时告警，不中断其余目标。
        # herdr 为可执行文件路径，targets 为目标标识符列表；无返回值。
        def init-herdr-integrations [herdr: path, targets: list<string>]: nothing -> nothing {
          let status = (^$herdr integration status | complete)
          if $status.exit_code != 0 {
            log warning $"Herdr integration status failed: ($status.stderr | str trim)"
            return
          }

          let statuses = ($status.stdout | str replace --all ' (experimental): ' ': ' | lines)
          for target in $targets {
            if ($statuses | any {|line| $line | str starts-with $"($target): current" }) {
              continue
            }

            let result = (^$herdr integration install $target | complete)
            if $result.exit_code == 0 {
              log info $"Herdr integration ready: ($target)"
            } else {
              log warning $"Herdr integration install failed for ($target): ($result.stderr | str trim)"
            }
          }
        }

        init-herdr-integrations "${cfg.package}/bin/herdr" ${builtins.toJSON cfg.integrations}
      '';
    };

    modules.shell.multiplexer.herdr.settings = {
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
        prompt_new_tab_name = mkDefault false;
        agent_panel_sort = mkDefault "spaces";
        show_agent_labels_on_pane_borders = mkDefault true;
        status_indicators = mkDefault "symbols";
        toast.delivery = mkDefault "system";
      };
      experimental = {
        pane_history = mkDefault false;
        reveal_hidden_cursor_for_cjk_ime = mkDefault true;
        cjk_ime_agents = mkDefault [
          "pi"
          "claude"
          "codex"
        ];
        switch_ascii_input_source_in_prefix = mkDefault true;
      };
      update = {
        channel = mkDefault "stable";
        version_check = mkDefault false;
        manifest_check = mkDefault false;
      };
      keys.prefix = mkDefault "ctrl+c";
      keys.focus_agent = mkDefault "prefix+alt+1..9";
      keys.switch_workspace = mkDefault "prefix+shift+1..9";
      keys.last_pane = mkDefault "prefix+backtick";
      keys.focus_pane_left = mkDefault [
        "prefix+h"
        "prefix+left"
      ];
      keys.focus_pane_down = mkDefault [
        "prefix+j"
        "prefix+down"
      ];
      keys.focus_pane_up = mkDefault [
        "prefix+k"
        "prefix+up"
      ];
      keys.focus_pane_right = mkDefault [
        "prefix+l"
        "prefix+right"
      ];
      keys.switch_tab = mkDefault [
        "prefix+1..9"
        "alt+1..9"
      ];
    };
  };
}
