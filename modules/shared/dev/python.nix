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
  cfg = cfm.dev.python;
in {
  options.modules.dev.python = {
    enable = mkEnableOption "Whether to python";
  };
  config = mkIf cfg.enable {
    modules.python.extraPkgs = ps:
      with ps; [
        pip
        ipython
        setuptools
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
      pkgs.python3.pkgs.ruff-lsp
      pkgs.poetry
      pkgs.pyright
      pkgs.pipenv
    ];
    modules.shell = {
      env = {
        PYLINTHOME = "${config.my.hm.dataHome}/pylint";
        PYLINTRC = "${config.my.hm.configHome}/pylint/pylintrc";
        IPYTHONDIR = "${config.my.hm.configHome}/ipython";
      };
      aliases = {
        po = "poetry";
        ipy = "ipython --no-banner";
        ipylab = "ipython --pylab=qt5 --no-banner";
      };
    };
    modules.asdf.plugins = ["python"];
  };
}
