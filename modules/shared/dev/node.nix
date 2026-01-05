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
  cfm = config.modules;
  cfg = cfm.dev.js;
  homeDir = my.homedir;
  npm_config_userconfig = "${homeDir}/.config/npm/config";
  npm_config_cache = "${homeDir}/.cache/npm";
  # NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
  npm_config_prefix = "${homeDir}/.local/share/npm";
  node_repl_history = "${homeDir}/.cache/node/repl_history";
  pnpm_home = "${config.home.dataDir}/pnpm";
in
{
  options.modules.dev.js = {
    node = {
      enable = mkEnableOption "Whether to use node";
      package = mkOpt' types.package pkgs.nodejs "nodejs package";

    };
    bun.enable = mkEnableOption "Whether to use bun";
  };
  config = mkMerge [
    (mkIf cfg.node.enable {
      home.packages = with pkgs.nodePackages; [
        cfg.node.package
        pnpm
        typescript-language-server
        stylelint
        js-beautify
      ];
      home.configFile."npm/config".text = ''
        cache=${npm_config_cache}
        prefix=${npm_config_prefix}
      '';
      modules.shell.env = {
        NPM_CONFIG_USERCONFIG = npm_config_userconfig;
        NPM_CONFIG_CACHE = npm_config_cache;
        # NPM_CONFIG_TMP = npm_config_tmp;
        NPM_CONFIG_PREFIX = npm_config_prefix;
        NODE_REPL_HISTORY = node_repl_history;
        PNPM_HOME = pnpm_home;
        # PATH = [ "$(${pkgs.yarn}/bin/yarn global bin)" ];
      };
    })
    (mkIf cfg.bun.enable {
      home.programs.bun.enable = true;
      modules.shell.env = {
        # @see https://github.com/oven-sh/bun/issues/1678#issuecomment-1714380418
        # 用来设置 global 包按照目录，和缓存目录
        BUN_INSTALL = "$XDG_DATA_HOME/bun";
      };
    })
  ];
}
