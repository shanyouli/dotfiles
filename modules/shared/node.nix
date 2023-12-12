{
  config,
  pkgs,
  lib,
  options,
  ...
}:
with lib;
with lib.my; let
  homeDir = config.my.hm.dir;
  cfg = config.modules.node;
  npm_config_userconfig = "${homeDir}/.config/npm/config";
  npm_config_cache = "${homeDir}/.cache/npm";
  # NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
  npm_config_prefix = "${homeDir}/.local/share/npm";
  node_repl_history = "${homeDir}/.cache/node/repl_history";
  node = pkgs.nodejs;
  pnpm_home = "${config.my.hm.dataHome}/pnpm";
in {
  options.modules.node = with types; {enable = mkBoolOpt false;};
  config = mkIf cfg.enable {
    my = {
      user.packages =
        [
          node
          pkgs.nodePackages.pnpm
        ]
        ++ optionals config.modules.dev.enable [
          pkgs.nodePackages.typescript-language-server
          pkgs.nodePackages.stylelint
          pkgs.nodePackages.js-beautify
        ];
      hm.configFile."npm/config".text = ''
        cache=${npm_config_cache}
        prefix=${npm_config_prefix}
      '';
    };
    modules.asdf.plugins = ["nodejs"];
    modules.shell = {
      env = {
        NPM_CONFIG_USERCONFIG = npm_config_userconfig;
        NPM_CONFIG_CACHE = npm_config_cache;
        # NPM_CONFIG_TMP = "${NPM_CONFIG_TMP}";
        NPM_CONFIG_PREFIX = npm_config_prefix;
        NODE_REPL_HISTORY = node_repl_history;
        # NODE_PATH = "${NODE_GLOBAL}/lib";
        PNPM_HOME = pnpm_home;
        PATH = [pnpm_home];
        # PATH = [ "$(${pkgs.yarn}/bin/yarn global bin)" ];
      };
    };
  };
}
