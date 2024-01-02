{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.python;
in {
  options.modules.shell.python = with types; {
    extraPkgs = mkOption {
      type = nullOr selectorFunction;
      default = null;
      example = literalExample "ps: [ ps.orjson]";
      description = ''
        Extra packages available to Python. To get a list of
      '';
    };
    finalPkg = mkPkgReadOpt "The Python include with packages";
  };
  config = mkIf (cfg.extraPkgs != null) {
    modules.shell.python.finalPkg = pkgs.python3.withPackages cfg.extraPkgs;
    user.packages = [
      cfg.finalPkg
      pkgs.pipx # A better python command line installation tool
    ];
    modules.shell = {
      env = {
        PIP_CONFIG_FILE = "${config.home.configDir}/pip/pip.conf";
        PIP_LOG_FILE = "${config.home.dataDir}/pip/log";
        PYTHONSTARTUP = "${config.home.configDir}/python/config.py";
        PYTHON_EGG_CACHE = "${config.home.cacheDir}/python-eggs";
        JUPYTER_CONFIG_DIR = "${config.home.dataDir}/jupyter";
      };
      aliases = {
        py = "python";
        py2 = "python2";
        py3 = "python3";
      };
      rcInit = ''
        pipx() {
          (( $+commands[asdf] ))  && export PIPX_DEFAULT_PYTHON=$(asdf which python)
          command pipx "$@"
          unset PIPX_DEFAULT_PYTHON
        };
      '';
    };
  };
}
