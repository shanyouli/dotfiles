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
      XDG_CACHE_HOME = "${config.my.hm.cacheHome}";
      XDG_CONFIG_HOME = "${config.my.hm.configHome}";
      XDG_DATA_HOME = "${config.my.hm.dataHome}";
      XDG_BIN_HOME = "${config.my.hm.binHome}";
      XDG_STATE_HOME = "${config.my.hm.stateHome}";
      # Conform more programs to XDG conventions. The rest are handled by their
      # respective modules.
      __GL_SHADER_DISK_CACHE_PATH = "${config.my.hm.cacheHome}/nv";
      ASPELL_CONF = ''
        per-conf ${config.my.hm.configHome}/aspell/aspell.conf;
        personal ${config.my.hm.configHome}/aspell/en_US.pws;
        repl ${config.my.hm.configHome}/aspell/en.prepl;
      '';
      CUDA_CACHE_PATH = "${config.my.hm.cacheHome}/nv";
      HISTFILE = "${config.my.hm.dataHome}/bash/history";
      INPUTRC = "${config.my.hm.configHome}/readline/inputrc";
      LESSHISTFILE = "${config.my.hm.cacheHome}/lesshst";

      # Tools I don't use
      # SUBVERSION_HOME = "${config.my.hm.configHome}/subversion";
      # BZRPATH         = "${config.my.hm.configHome}/bazaar";
      # BZR_PLUGIN_PATH = "${config.my.hm.dataHome}/bazaar";
      # BZR_HOME        = "${config.my.hm.cacheHome}/bazaar";
      # ICEAUTHORITY    = "${config.my.hm.cacheHome}/ICEauthority";
    };
  };
}
