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
  cenv = pkgs.buildEnv {
    name = "python-build-env";
    paths = with pkgs; [xz.dev];
    pathsToLink = ["/lib" "/include"];
  };
in {
  options.modules.dev.python = with types; {
    enable = mkEnableOption "Whether to python";
    plugins = mkOpt' (listOf (nullOr str)) [] "Use asdf install python version";
  };
  config = mkIf cfg.enable {
    modules.shell.python.extraPkgs = ps:
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
    user.packages = [
      pkgs.ruff
      pkgs.python3.pkgs.ruff-lsp
      pkgs.poetry
      pkgs.pyright
      pkgs.pipenv
    ];
    modules.shell = {
      env = {
        PYLINTHOME = "${config.home.dataDir}/pylint";
        PYLINTRC = "${config.home.config.dotfiles.configDir}/pylint/pylintrc";
        IPYTHONDIR = "${config.home.config.dotfiles.configDir}/ipython";
      };
      aliases = {
        po = "poetry";
        ipy = "ipython --no-banner";
        ipylab = "ipython --pylab=qt5 --no-banner";
      };
    };
    home.dataFile."benv/python" = {
      source = "${cenv}";
      recursive = true;
    };
    modules.dev.plugins = ["python"];
    modules.dev.pltext = optionalString (cfg.plugins != []) ''
      export CFLAGS="-I${config.home.dataDir}/benv/python/include"
      export CPPFLAGS="-I${config.home.dataDir}/benv/python/include"
      export LDFLAGS="-L${config.home.dataDir}/benv/python/lib"
      ${asdfInPlugins "${cfm.dev.package}/bin/asdf" "python" cfg.plugins}
      unset CFLAGS LDFLAGS CPPFLAGS
    '';
  };
}
