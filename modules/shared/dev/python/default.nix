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
  managers = ["poetry" "rye"];
in {
  options.modules.dev.python = with types; {
    enable = mkEnableOption "Whether to python";
    versions = mkOpt' (oneOf [str (nullOr bool) (listOf (nullOr str))]) [] "Use asdf install python version";
    manager = mkOption {
      description = "python virtual environment management tools";
      type = str;
      default = "poetry";
      apply = s:
        if builtins.elem s managers
        then s
        else "";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.manager == "poetry") {
      modules.dev.python.poetry.enable = true;
    })
    {
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
      user.packages = with pkgs; [
        ruff
        python3.pkgs.ruff-lsp
        # pyright
        unstable.basedpyright
        pipenv
      ];
      modules.shell = {
        env = {
          PYLINTHOME = "${config.home.dataDir}/pylint";
          PYLINTRC = "${config.home.configDir}/pylint/pylintrc";
          IPYTHONDIR = "${config.home.configDir}/ipython";
        };
        aliases = {
          ipy = "ipython --no-banner";
          ipylab = "ipython --pylab=qt5 --no-banner";
        };
      };
      home.dataFile."benv/python" = {
        source = "${cenv}";
        recursive = true;
      };
      modules.editor.helix = {
        # extraPackages = with pkgs; [];
        languages = {
          language = [
            {
              name = "python";
              language-servers = ["ruff-lsp" "pyright"];
              formatter = {
                command = "ruff";
                args = ["--quiet" "-"];
              };
            }
          ];
          language-server.pyright.config.python.analysis.typeCheckingMode = "basic";
          language-server.ruff-lsp.command = "ruff-lsp";
          language-server.ruff-lsp.config.settings.args = ["--ignore" "E501"];
        };
      };
    }
    (mkIf (cfg.versions != []) {
      modules.dev.lang.python = cfg.versions;
      modules.dev.manager.prevInit = ''
        export CFLAGS="-I${config.home.dataDir}/benv/python/include $CFLAGS"
        export CPPFLAGS="-I${config.home.dataDir}/benv/python/include $CPPFLAGS"
        export LDFLAGS="-L${config.home.dataDir}/benv/python/lib $LDFLAGS"
      '';
      modules.dev.manager.extInit = ''
        unset CFLAGS LDFLAGS CPPFLAGS
      '';
    })
  ]);
}
