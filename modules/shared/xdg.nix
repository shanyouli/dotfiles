{
  lib,
  config,
  options,
  home-manager,
  pkgs,
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

    # 用来提示还有那些可以规范的文件。如何使用
    environment.systemPackages = [pkgs.xdg-ninja];

    # Get Nix (2.14+) itself to respect XDG. I.e.
    # ~/.nix-defexpr -> $XDG_DATA_HOME/nix/defexpr
    # ~/.nix-profile -> $XDG_DATA_HOME/nix/profile
    # ~/.nix-channels -> $XDG_DATA_HOME/nix/channels
    nix.settings.use-xdg-base-directories = true;

    modules.xdg.value = {
      # These are the defaults, and xdg.enable does set them, but due to load
      # order, they're not set before environment.variables are set, which could
      # cause race conditions.
      XDG_CACHE_HOME = "${config.home.cacheDir}";
      XDG_CONFIG_HOME = "${config.home.configDir}";
      XDG_DATA_HOME = "${config.home.dataDir}";
      XDG_BIN_HOME = "${config.home.binDir}";
      XDG_STATE_HOME = "${config.home.stateDir}";
      XDG_RUNTIME_DIR =
        if pkgs.stdenvNoCC.isDarwin
        then "/tmp/user/${toString config.user.uid}"
        else "/run/user/${toString config.user.uid}";

      # Conform more programs to XDG conventions. The rest are handled by their
      # respective modules.
      __GL_SHADER_DISK_CACHE_PATH = "${config.home.cacheDir}/nv";
      ASPELL_CONF = ''
        per-conf ${config.home.configDir}/aspell/aspell.conf;
        personal ${config.home.configDir}/aspell/en_US.pws;
        repl ${config.home.configDir}/aspell/en.prepl;
      '';
      CUDA_CACHE_PATH = "${config.home.cacheDir}/nv";
      HISTFILE = "${config.home.dataDir}/bash/history";
      INPUTRC = "${config.home.configDir}/readline/inputrc";
      LESSHISTFILE = "${config.home.cacheDir}/lesshst";

      # Tools I don't use
      # SUBVERSION_HOME = "${config.home.configDir}/subversion";
      # BZRPATH         = "${config.home.configDir}/bazaar";
      # BZR_PLUGIN_PATH = "${config.home.dataDir}/bazaar";
      # BZR_HOME        = "${config.home.cacheDir}/bazaar";
      # ICEAUTHORITY    = "${config.home.cacheDir}/ICEauthority";

      # .dotnet 文件 to $XDG_DATA_HOME/dotnet
      DOTNET_CLI_HOME = "${config.home.dataDir}/dotnet";

      # .gem to $XDG_CACHE_HOME
      GEM_HOME = "${config.home.dataDir}/gem";
      GEM_SPAC_HOME = "${config.home.cacheDir}/gem";

      # MPLCONFIGDIR
      MPLCONFIGDIR = "${config.home.cacheDir}/matplotlib";

      # .openjfx to $XDG_CACHE_DIR
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.home.cacheDir}/java -Djavafx.cachedir=${config.home.cacheDir}/openjfx";

      # .docker
      DOCKER_CONFIG = "${config.home.configDir}/docker";
    };
  };
}
