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
    enable = mkBoolOpt false;
    extraPkgs = mkOption {
      default = self: [];
      type = selectorFunction;
      defaultText = "ps: [ ps.orjson ]";
      example = literalExample "ps: [ ps.orjson]";
      description = ''
        Extra packages available to Python. To get a list of
      '';
    };
    finalPkg = mkPkgReadOpt "The Python include with packages";
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf config.my.modules.dev.enable {
      my.modules.python.extraPkgs = ps:
        with ps; [
          isort
          nose
          pytest
          pygments
          rich
          pylint
          pylint-venv
        ];
      my.user.packages = [
        pkgs.ruff
        pkgs.pyright
        pkgs.pipx # pipx cmd管理工具
        pkgs.python3.pkgs.ruff-lsp
        pkgs.stable.black
        pkgs.stable.poetry
        pkgs.stable.pipenv
      ];
      my.modules.zsh = {
        env = {
          PYLINTHOME = "${config.my.hm.dataHome}/pylint";
          PYLINTRC = "${config.my.hm.configHome}/pylint/pylintrc";
        };
        aliases = {
          po = "poetry";
          ipy = "ipython --no-banner";
          ipylab = "ipython --pylab=qt5 --no-banner";
        };
      };
      my.modules.asdf.plugins = ["python"];
    })
    {
      my.modules.python.finalPkg = pkgs.python3.withPackages cfg.extraPkgs;
      my.user.packages = [
        cfg.finalPkg
        # pyEnv
        pkgs.python3.pkgs.pip
        pkgs.python3.pkgs.ipython
        pkgs.python3.pkgs.setuptools
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
    }
  ]);
}
