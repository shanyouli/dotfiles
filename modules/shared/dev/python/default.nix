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
  managers = ["poetry" "rye"];
in {
  options.modules.dev.python = with types; {
    enable = mkEnableOption "Whether to python";
    # 如果使用 asdf 管理版本。versions 的值需要符合：`asdf list all python` 的结果
    # 如果使用 mise 管理版本的值需要符合 `mise ls-remote python` 的结果
    # 如果使用 rye 管理版本，versions 需要符合 `rye toolchain list --include-downloadable` 的结果
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
    (mkIf (cfg.manager == "rye") {
      modules.dev.python.rye.enable = true;
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
    (mkIf ((cfg.manager != "rye") || (cfg.rye.manager == false)) {
      modules.dev.lang.python = cfg.versions;
    })
  ]);
}
