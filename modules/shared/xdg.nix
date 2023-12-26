{
  lib,
  config,
  options,
  home-manager,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.xdg;
in {
  options.modules.xdg = {
    enable = mkEnableOption "Whether to use xdg compliance";
    value = mkOpt types.attrs {};
  };
  config = mkIf cfg.enable {
    home-manager.users.${config.user.name}.xdg.enable = true;
    modules.xdg.value = {
      # These are the defaults, and xdg.enable does set them, but due to load
      # order, they're not set before environment.variables are set, which could
      # cause race conditions.
      XDG_CACHE_HOME = "${config.home.cacheDir}";
      XDG_CONFIG_HOME = "${config.home.config.dotfiles.configDir}";
      XDG_DATA_HOME = "${config.home.dataDir}";
      XDG_BIN_HOME = "${config.home.binDir}";
      XDG_STATE_HOME = "${config.home.stateDir}";
      # Conform more programs to XDG conventions. The rest are handled by their
      # respective modules.
      __GL_SHADER_DISK_CACHE_PATH = "${config.home.cacheDir}/nv";
      ASPELL_CONF = ''
        per-conf ${config.home.config.dotfiles.configDir}/aspell/aspell.conf;
        personal ${config.home.config.dotfiles.configDir}/aspell/en_US.pws;
        repl ${config.home.config.dotfiles.configDir}/aspell/en.prepl;
      '';
      CUDA_CACHE_PATH = "${config.home.cacheDir}/nv";
      HISTFILE = "${config.home.dataDir}/bash/history";
      INPUTRC = "${config.home.config.dotfiles.configDir}/readline/inputrc";
      LESSHISTFILE = "${config.home.cacheDir}/lesshst";

      # Tools I don't use
      # SUBVERSION_HOME = "${config.home.config.dotfiles.configDir}/subversion";
      # BZRPATH         = "${config.home.config.dotfiles.configDir}/bazaar";
      # BZR_PLUGIN_PATH = "${config.home.dataDir}/bazaar";
      # BZR_HOME        = "${config.home.cacheDir}/bazaar";
      # ICEAUTHORITY    = "${config.home.cacheDir}/ICEauthority";
    };
  };
}
