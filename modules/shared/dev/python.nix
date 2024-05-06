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
  config = mkIf cfg.enable (mkMerge [
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
        poetry
        pyright
        pipenv
      ];
      modules.shell = {
        env = {
          PYLINTHOME = "${config.home.dataDir}/pylint";
          PYLINTRC = "${config.home.configDir}/pylint/pylintrc";
          IPYTHONDIR = "${config.home.configDir}/ipython";
        };
        aliases = {
          po = "poetry";
          ipy = "ipython --no-banner";
          ipylab = "ipython --pylab=qt5 --no-banner";
        };
        direnv.stdlib.poetry = pkgs.writeScript "poetry" ''
          #!/usr/bin/env bash
          use_poetry() {
              PYPROJECT_TOML="''${PYPROJECT_TOML:-pyproject.toml}"
              if [[ ! -f "$PYPROJECT_TOML" ]]; then
                  log_status "No pyproject.toml found. Executing \`poetry init\` to create a \`$PYPROJECT_TOML\` first."
                  poetry init
              fi

              VIRTUAL_ENV=$(poetry env info --path 2>/dev/null ; true)

              if [ -z "$VIRTUAL_ENV" ] || [ ! -d "$VIRTUAL_ENV" ]; then
                  log_status "No virtual environment exists. Executing \`poetry install\` to create one."
                  poetry install
                  VIRTUAL_ENV=$(poetry env info --path)
              fi

              PATH_add "$VIRTUAL_ENV/bin"
              export POETRY_ACTIVE=1
              export VIRTUAL_ENV
          }
        '';
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
              formatters = {
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
    (mkIf (cfg.plugins != []) {
      modules.dev.plugins.python = cfg.plugins;
      modules.dev.prevInit = ''
        export CFLAGS="-I${config.home.dataDir}/benv/python/include $CFLAGS"
        export CPPFLAGS="-I${config.home.dataDir}/benv/python/include $CPPFLAGS"
        export LDFLAGS="-L${config.home.dataDir}/benv/python/lib $LDFLAGS"
      '';
      modules.dev.extInit = ''
        unset CFLAGS LDFLAGS CPPFLAGS
      '';
    })
  ]);
}
