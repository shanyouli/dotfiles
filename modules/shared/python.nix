{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.python;
in {
  options.my.modules.python = with types; {
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
    my.modules.python.finalPkg = pkgs.python3.withPackages cfg.extraPkgs;
    my.user.packages = [
      cfg.finalPkg
      pkgs.stable.pipx # A better python command line installation tool
    ];
    my.modules.zsh = {
      env = {
        IPYTHONDIR = "${config.my.hm.configHome}/ipython";
        PIP_CONFIG_FILE = "${config.my.hm.configHome}/pip/pip.conf";
        PIP_LOG_FILE = "${config.my.hm.dataHome}/pip/log";
        PYTHONSTARTUP = "${config.my.hm.configHome}/python/config.py";
        PYTHON_EGG_CACHE = "${config.my.hm.cacheHome}/python-eggs";
        JUPYTER_CONFIG_DIR = "${config.my.hm.dataHome}/jupyter";
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
