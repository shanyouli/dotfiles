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
  cfg = config.modules.dev.js;
in
{
  options.modules.dev.js = {
    enable = mkEnableOption "Whether to use javascript.";
    ts.enable = mkBoolOpt' cfg.enable "Whether to use typeScript.";
    fmt = {
      enable = mkBoolOpt' cfg.enable ''
        Whether to format js, ts, jsonc, json, css by oxfmt.
        @see https://oxc.rs/docs/guide/usage/formatter.html
      '';
      package = mkPackageOption pkgs "oxfmt" { };
    };
    lint = {
      enable = mkBoolOpt' cfg.enable ''
        Whether to lint js, ts by oxlint.
        @see https://oxc.rs/docs/guide/usage/linter.html
      '';
      package = mkPackageOption pkgs "oxlint" { };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        # 运行时固定为最新 LTS 的 node；包管理固定用 aube，aubeshim 提供 shell 集成
        pkgs.nodejs
        pkgs.unstable.aube
        pkgs.aubeshim
        # CSS 检查由 stylelint 负责（仅提供命令，配置随项目走，仓库内 CSS 无默认 lint 覆盖）
        pkgs.stylelint
        (mkIf cfg.fmt.enable cfg.fmt.package)
        (mkIf cfg.lint.enable cfg.lint.package)
      ];
      modules.shell = {
        env = {
          # aube 全局包安装目录
          AUBE_GLOBAL_BIN_DIR = "$XDG_DATA_HOME/aube/bin";
          PATH = [ "$AUBE_GLOBAL_BIN_DIR" ];
        };
        zsh.rcInit = mkOrder 1000 "_cache -v ${pkgs.aubeshim.version} aubeshim activate zsh";
        fish.rcInit = mkOrder 1000 "_cache -v ${pkgs.aubeshim.version} aubeshim activate fish";
        # nushell.cacheCmd = mkOrder 1000 ["${pkgs.aubeshim}/bin/aubeshim activate nushell" ];
      };
    }
    (mkIf cfg.ts.enable {
      home.packages = [
        pkgs.typescript
        pkgs.typescript-language-server
      ];
    })
  ]);
}
