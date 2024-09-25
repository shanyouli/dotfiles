{
  lib,
  my,
  config,
  ...
}:
with lib;
with my; {
  # Get Nix (2.14+) itself to respect XDG. I.e.
  # ~/.nix-defexpr -> $XDG_DATA_HOME/nix/defexpr
  # ~/.nix-profile -> $XDG_DATA_HOME/nix/profile
  # ~/.nix-channels -> $XDG_DATA_HOME/nix/channels
  nix.settings.use-xdg-base-directories = true;
  env = {
    DOTFILES = my.dotfiles.dir;
    NIXPKGS_ALLOW_UNFREE = "1";

    # Conform more programs to XDG conventions. The rest are handled by their
    # respective modules.
    __GL_SHADER_DISK_CACHE_PATH = ''"$XDG_CACHE_HOME"/nv'';
    ASPELL_CONF = ''
      per-conf "$XDG_CONFIG_HOME"/aspell/aspell.conf;
      personal "$XDG_CONFIG_HOME"/aspell/en_US.pws;
      repl "$XDG_CONFIG_HOME"/aspell/en.prepl;
    '';
    CUDA_CACHE_PATH = ''"$XDG_CACHE_HOME"/nv'';
    HISTFILE = ''"$XDG_DATA_HOME"/bash/history'';
    INPUTRC = ''"$XDG_CONFIG_HOME"/readline/inputrc'';
    LESSHISTFILE = ''"$XDG_CACHE_HOME"/lesshst'';

    # Tools I don't use
    SUBVERSION_HOME = ''"$XDG_CONFIG_HOME"/subversion'';
    BZRPATH = ''"$XDG_CONFIG_HOME"/bazaar'';
    BZR_PLUGIN_PATH = ''"$XDG_DATA_HOME"/bazaar'';
    BZR_HOME = ''"$XDG_CACHE_HOME"/bazaar'';
    ICEAUTHORITY = ''"$XDG_CACHE_HOME"/ICEauthority'';

    # .dotnet 文件 to $XDG_DATA_HOME/dotnet
    DOTNET_CLI_HOME = ''"$XDG_DATA_HOME"/dotnet'';

    # .gem to $XDG_CACHE_HOME
    GEM_HOME = ''"$XDG_DATA_HOME"/gem'';
    GEM_SPEC_CACHE = ''"$XDG_CACHE_HOME"/gem'';

    # .bundle
    BUNDLE_USER_CONFIG = ''"$XDG_CONFIG_HOME"/bundle'';
    BUNDLE_USER_CACHE = ''"$XDG_CACHE_HOME"/bundle'';
    BUNDLE_USER_PLUGIN = ''"$XDG_DATA_HOME"/bundle'';
    # .sqlite_history
    SQLITE_HISTORY = ''"$XDG_CACHE_HOME"/sqlite_history'';

    # MPLCONFIGDIR
    MPLCONFIGDIR = ''"$XDG_CACHE_HOME"/matplotlib'';

    # .openjfx to $XDG_CACHE_DIR
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=$XDG_CACHE_DIR/java -Djavafx.cachedir=$XDG_CACHE_DIR/openjfx";

    # .docker
    DOCKER_CONFIG = ''"$XDG_CONFIG_HOME"/docker'';
  };
  home.actionscript = ''
    echo-info "Create fakeHome"
    fakehome="${config.home.fakeDir}"
    mkdir -p "$fakehome" -m 755
    [[ -e "$fakehome/.local" ]] || ln -sf ~/.local "$fakehome/.local"
    [[ -e "$fakehome/.config" ]] || ln -sf ~/.config "$fakehome/.config"
  '';
}
