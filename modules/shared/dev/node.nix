{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.dev.node;
  homeDir = config.user.home;
  npm_config_userconfig = "${homeDir}/.config/npm/config";
  npm_config_cache = "${homeDir}/.cache/npm";
  # NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
  npm_config_prefix = "${homeDir}/.local/share/npm";
  node_repl_history = "${homeDir}/.cache/node/repl_history";
  pnpm_home = "${config.home.dataDir}/pnpm";
in {
  options.modules.dev.node = {
    enable = mkEnableOption "Whether to use node";
    package = mkOpt' types.package pkgs.stable.nodejs "nodejs package";
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs.stable.nodePackages; [
      cfg.package
      pnpm
      typescript-language-server
      stylelint
      js-beautify
      pkgs.stable.bun
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
  };
}
