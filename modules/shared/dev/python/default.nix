{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.dev.python;
  managers = [
    "uv"
    "mise"
  ];
  venvs = [
    "poetry"
    "uv"
  ];
  versionsConfigured =
    !(builtins.elem cfg.versions [
      null
      false
      true
      [ ]
    ]);
  usesDevManager =
    cfg.manager == "mise" || (cfg.manager == "" && cfg.venv != "uv" && versionsConfigured);
  devManager = "mise";
  effectiveManager =
    if cfg.manager != "" then
      cfg.manager
    else if builtins.elem cfg.venv managers then
      cfg.venv
    else if usesDevManager then
      devManager
    else
      "";
in
{
  options.modules.dev.python = with types; {
    enable = mkEnableOption "Whether to python";
    # 如果使用 mise 管理版本的值需要符合 `mise ls-remote python` 的结果
    # 如果使用 uv 管理版本， versions 需要符合 'uv python list --all-versions' 的结果。
    versions = mkOpt' (oneOf [
      str
      (nullOr bool)
      (listOf (nullOr str))
    ]) [ ] "Use mise install python version";
    global = mkOption {
      description = "python default version";
      type = str;
      default = "";
      apply =
        s:
        if builtins.isString cfg.versions then
          cfg.versions
        else if
          (builtins.elem cfg.versions [
            null
            false
            true
            [ ]
          ])
        then
          ""
        else if builtins.elem s cfg.versions then
          s
        else
          "";
    };
    venv = mkOption {
      description = "python virtual environment management tool.";
      type = str;
      default = "poetry";
      apply = s: if builtins.elem s venvs then s else "";
    };
    manager = mkOption {
      description = "python versions management tool.";
      type = str;
      default = "";
      apply = s: if builtins.elem s managers then s else "";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules = {
        dev.lang = mkIf usesDevManager { python = cfg.versions; };
        dev.python = {
          poetry.enable = mkDefault (cfg.venv == "poetry");
          uv = {
            enable = mkDefault (cfg.venv == "uv");
            manager = mkDefault (effectiveManager == "uv");
          };
        };
        python.extraPkgs =
          ps: with ps; [
            pip
            ipython
            setuptools
            isort
            # nose # nose 目前不支持 python3.12
            pytest
            pygments
            rich
            pylint
            pylint-venv
          ];
        app.editor = {
          helix = {
            # extraPackages = with pkgs; [];
            languages = {
              language = [
                {
                  name = "python";
                  language-servers = [
                    "ruff-lsp"
                    "pyright"
                  ];
                  formatter = {
                    command = "ruff";
                    args = [
                      "--quiet"
                      "-"
                    ];
                  };
                }
              ];
              language-server = {
                pyright.config.python.analysis.typeCheckingMode = "basic";
                ruff-lsp = {
                  command = "ruff";
                  config.settings.args = [
                    "server"
                    "--ignore"
                    "E501"
                  ];
                };
              };
            };
          };
        };
        shell = {
          env = {
            PYLINTHOME = "$XDG_DATA_HOME/pylint";
            PYLINTRC = "$XDG_CONFIG_HOME/pylint/pylintrc";
            IPYTHONDIR = "$XDG_CONFIG_HOME/ipython";
          };
          aliases = {
            ipy = "ipython --no-banner";
            ipylab = "ipython --pylab=qt5 --no-banner";
          };
        };
      };
      home = {
        configFile."python" = {
          source = "${my.paths.dotfiles.config}/python";
          recursive = true;
        };
        packages = with pkgs; [
          basedpyright
          pipenv
          ty
        ];
      };
    }
    (mkIf usesDevManager {
      modules.dev = {
        manager.global.python = mkIf (cfg.global != "") cfg.global;
      };
    })
  ]);
}
