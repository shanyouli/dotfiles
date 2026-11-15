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
  # 版本管理器只有两种：uv（未指定时的默认）与 mise（需显式指定）；
  # 虚拟环境与用户级工具安装固定走 uv。
  usesDevManager = cfg.manager == "mise";
  effectiveManager = if cfg.manager != "" then cfg.manager else "uv";
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
  };
  config = mkMerge [
    (mkIf cfg.enable (mkMerge [
      {
        modules = {
          dev.lang = mkIf usesDevManager { python = cfg.versions; };
          dev.python = {
            uv = {
              # 已在 mkIf cfg.enable 内，uv 跟随 python 启用；host 可显式覆盖。
              enable = mkDefault true;
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
  ];
}
