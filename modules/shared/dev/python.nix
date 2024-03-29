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
