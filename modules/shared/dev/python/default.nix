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
        else if s == "" then
          ""
        else if builtins.elem s cfg.versions then
          s
        else
          throw "modules.dev.python.global = \"${s}\" 不在 modules.dev.python.versions 中";
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
    extraPkgs = mkOption {
      type = nullOr selectorFunction;
      default = null;
      example = literalExpression "ps: [ ps.orjson]";
      description = "Extra packages available to Python.";
    };
    finalPkg = mkPkgReadOpt "The Python include with packages";
    pipx.enable = mkBoolOpt true;
  };
  config = mkMerge [
    (mkIf cfg.enable (mkMerge [
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
          dev.python.extraPkgs =
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
          editor = {
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
    ]))
    {
      modules = {
        shell = {
          aliases = {
            py = "python";
            py2 = "python2";
            py3 = "python3";
          };
          env = {
            PIP_CONFIG_FILE = "$XDG_CONFIG_HOME/pip/pip.conf";
            PIP_LOG_FILE = "$XDG_DATA_HOME/pip/log";
            PYTHONSTARTUP = "$XDG_CONFIG_HOME/python/config.py";
            PYTON_EGG_CACHE = "$XDG_CACHE_HOME/python-eggs";
            JUPYTER_CONFIG_DIR = "$XDG_DATA_HOME/jupyter";
          };
        };
        dev.python.finalPkg =
          if cfg.extraPkgs != null then pkgs.python3.withPackages cfg.extraPkgs else pkgs.python3;
      };
      home.packages = [ cfg.finalPkg ];
    }
    (mkIf cfg.pipx.enable (
      let
        cmdp = config.modules.dev.python;
        global_python_path =
          if cmdp.enable && (cmdp.global != "") then "mise where python@${cmdp.global}" else "";
        pipx_function_text = ''
          pipx() {
            local _is_pipx_default=$PIPX_DEFAULT_PYTHON
            if [[ -z $_is_pipx_default ]]; then
              export PIPX_DEFAULT_PYTHON="$(readlink -f $(${global_python_path})/bin/python)"
            fi
            command pipx "$@"
            if [[ -z $_is_pipx_default ]]; then
              unset PIPX_DEFAULT_PYTHON
            fi
          };
        '';
      in
      {
        # A better python command line installation tool
        modules.shell = {
          zsh.rcInit = lib.optionalString (global_python_path != "") pipx_function_text;
          nushell.rcInit = lib.optionalString (global_python_path != "") ''
            export def --wrapped pipx [...rest: string] {
                if ($env | get -o PIPX_DEFAULT_PYTHON | is-empty) {
                    let pipx_default_python = ([( ${global_python_path} ), "bin", "python" ] | path join | readlink -f $in)
                    with-env {PIPX_DEFAULT_PYTHON: $pipx_default_python } {
                        ^pipx ...$rest
                    }
                } else {
                    ^pipx ...$rest
                }
            }
          '';
        };
        home = {
          packages = [ pkgs.python3Packages.pipx ];
          programs.bash.initExtra = lib.optionalString (global_python_path != "") pipx_function_text;
        };
      }
    ))
  ];
}
