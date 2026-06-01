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
  cfp = config.modules.dev;
  cfg = cfp.js;
in
{
  options.modules.dev.js = {
    enable = mkEnableOption "Whether to use javascript.";
    ts.enable = mkBoolOpt' cfg.enable "Whether to use typeScript.";
    node = {
      enable = mkBoolOpt' cfg.enable "Node";
      env = mkOption {
        description = "Node default run env.";
        type = types.str;
        default = "";
        apply =
          s:
          if
            builtins.elem s [
              "bun"
              "node"
              "deno"
            ]
          then
            s
          else
            "node";
      };
      package = mkPackageOption pkgs (if cfg.node.env == "node" then "nodejs" else cfg.node.env) { };
    };
    manager = {
      name = mkOption {
        description = "node modules manager tools.";
        type = types.str;
        default = "aube";
        apply =
          s:
          if
            builtins.elem s [
              "deno"
              "bun"
              "npm"
              "pnpm"
              "aube"
              "yarn"
            ]
          then
            s
          else
            "npm";
      };
      # 当 package 为 null,时意味着不使用系统管理器来按照它们；
      package = mkPackageOption (
        if cfg.manager.name == "aube" then pkgs.unstable else pkgs
      ) cfg.manager.name { nullable = true; };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        pkgs.stylelint # CSS linter
      ];
      modules.shell.env = {
        # PNPM 相关环境变量。目前来看，它不需要特殊设置，see @https://pnpm.io/zh/settings#cachedir
        # yarn 不支持 xdg see@https://github.com/b3nj5m1n/xdg-ninja/blob/main/programs/yarn.json
        # NPM 相关环境变量。see@https://github.com/b3nj5m1n/xdg-ninja/blob/main/programs/npm.json
        NPM_CONFIG_INIT_MODULE = "$XDG_CONFIG_HOME/npm/config/npm-init.js";
        NPM_CONFIG_CACHE = "$XDG_CACHE_HOME/npm";
        NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
        # DENO 也支持 XDG ，但还是建议设置
        DENO_DIR = "$XDG_CACHE_HOME/deno";
        DENO_INSTALL_ROOT = "$XDG_DATA_HOME/deno";
        # @see https://github.com/oven-sh/bun/issues/1678#issuecomment-1714380418
        # 用来设置 global 包按照目录，和缓存目录
        BUN_INSTALL = "$XDG_DATA_HOME/bun";
        # yarn see@https://raybyte.cn/post/2026/4/9/0ee62c6f
        YARN_CACHE_FOLDER = "$XDG_CACHE_HOME/yarn";
        YARN_GLOBAL_FOLDER = "$XDG_DATA_HOME/yarn";
        # aube
        AUBE_GLOBAL_BIN_DIR = "$XDG_DATA_HOME/aube/bin";
        PATH = [
          (mkIf (cfg.manager.name == "pnpm") "$XDG_DATA_HOME/pnpm/bin")
          (mkIf (cfg.manager.name == "yarn") "$YARN_GLOBAL_FOLDER/bin")
          (mkIf (cfg.manager.name == "npm") "$XDG_CACHE_HOME/npm/bin")
          (mkIf (cfg.manager.name == "aube") "$AUBE_GLOBAL_BIN_DIR")
          (mkIf (builtins.elem "bun" [
            cfg.manager.name
            cfg.node.env
          ]) "$BUN_INSTALL/bin")
          (mkIf (builtins.elem "deno" [
            cfg.manager.name
            cfg.node.env
          ]) "$DENO_INSTALL_ROOT/bin")
        ];
      };
    }
    (mkIf (cfg.node.env == cfg.manager.name) {
      modules.dev.js.manager.package = mkForce cfg.node.package;
      home.packages = [ cfg.node.package ];
    })
    (mkIf (cfg.node.env != cfg.manager.name) {
      home.packages = [
        cfg.node.package
        cfg.manager.package
        (mkIf (cfg.node.env != "nodejs") pkgs.nodejs)
      ];
    })
    (mkIf cfg.ts.enable {
      home.packages = [
        pkgs.typescript
        pkgs.typescript-language-server
      ];
    })
  ]);
}
