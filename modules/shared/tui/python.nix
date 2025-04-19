{
  config,
  lib,
  pkgs,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.python;
in
{
  options.modules.python = with types; {
    extraPkgs = mkOption {
      type = nullOr selectorFunction;
      default = null;
      example = literalExample "ps: [ ps.orjson]";
      description = ''
        Extra packages available to Python. To get a list of
      '';
    };
    finalPkg = mkPkgReadOpt "The Python include with packages";
    pipx.enable = mkBoolOpt true;
  };
  config = mkMerge [
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
        python.finalPkg =
          if cfg.extraPkgs != null then pkgs.python3.withPackages cfg.extraPkgs else pkgs.python3;
      };
      home.packages = [ cfg.finalPkg ];
    }
    (mkIf cfg.pipx.enable (
      let
        cmdp = config.modules.dev.python;
        use_rye_p = (cmdp.manager == "rye") && cmdp.rye.manager;
        global_python_path =
          if cmdp.enable && (cmdp.global != "") then
            (
              if use_rye_p then
                "rye toolchain list --format json"
              else
                (
                  if config.modules.dev.manager.default == "asdf" then
                    "asdf where python ${cmdp.global}"
                  else
                    (if config.modules.dev.manager.default == "mise" then "mise where python@${cmdp.global}" else "")
                )
            )
          else
            "";
        pipx_function_text = ''
          pipx() {
            local _is_pipx_default=$PIPX_DEFAULT_PYTHON
            if [[ -z $_is_pipx_default ]]; then
              ${lib.optionalString use_rye_p ''
                export PIPX_DEFAULT_PYTHON="$(readlink -f $(${global_python_path} | jq -r '[.[] | select(.name | contains("${cmdp.global}"))].[0].path'))"
              ''}
              ${lib.optionalString (!use_rye_p) ''
                export PIPX_DEFAULT_PYTHON="$(readlink -f $(${global_python_path})/bin/python)"
              ''}
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
                if ($env | get --ignore-errors PIPX_DEFAULT_PYTHON | is-empty) {
                    ${lib.optionalString use_rye_p ''
                      let pipx_default_python = (${global_python_path} | from json | where ($it.name | str contains "${cmdp.global}") | get path | first | readlink -f $in)
                    ''}
                    ${lib.optionalString (!use_rye_p) ''
                      let pipx_default_python = ([( ${global_python_path} ), "bin", "python" ] | path join | readlink -f $in)
                    ''}
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
          packages = [ pkgs.pipx ];
          programs.bash.initExtra = lib.optionalString (global_python_path != "") pipx_function_text;
        };
        # nushell.cmpFiles = ["${my.dotfiles.config}/pipx/pipx-completions.nu"];
      }
    ))
  ];
}
