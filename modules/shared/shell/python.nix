{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.python;
in {
  options.modules.shell.python = with types; {
    extraPkgs = mkOption {
      type = nullOr selectorFunction;
      default = null;
      example = literalExample "ps: [ ps.orjson]";
      description = ''
        Extra packages available to Python. To get a list of
      '';
    };
    finalPkg = mkPkgReadOpt "The Python include with packages";
  };
  config = mkIf (cfg.extraPkgs != null) {
    user.packages = [
      cfg.finalPkg
      pkgs.pipx # A better python command line installation tool
    ];
    modules.shell = let
      cmdp = config.modules.dev.python;
      use_rye_p = (cmdp.manager == "rye") && cmdp.rye.manager;
      global_python_path =
        if cmdp.enable && (cmdp.global != "")
        then
          (
            if use_rye_p
            then "rye toolchain list --format json"
            else
              (
                if config.modules.dev.manager.default == "asdf"
                then "asdf where python ${cmdp.global}"
                else
                  (
                    if config.modules.dev.manager.default == "mise"
                    then "mise where python@${cmdp.global}"
                    else ""
                  )
              )
          )
        else "";
    in {
      python.finalPkg = pkgs.python3.withPackages cfg.extraPkgs;
      env = {
        PIP_CONFIG_FILE = "${config.home.configDir}/pip/pip.conf";
        PIP_LOG_FILE = "${config.home.dataDir}/pip/log";
        PYTHONSTARTUP = "${config.home.configDir}/python/config.py";
        PYTHON_EGG_CACHE = "${config.home.cacheDir}/python-eggs";
        JUPYTER_CONFIG_DIR = "${config.home.dataDir}/jupyter";
      };
      aliases = {
        py = "python";
        py2 = "python2";
        py3 = "python3";
      };
      cmpFiles = ["pipx"];
      rcInit = lib.optionalString (global_python_path != "") ''
        pipx() {
          if [[ -z "''${_comps[_pipx]}" ]]; then
            _comps[pipx]=_pipx
          fi
          local _is_pipx_default=$PIPX_DEFAULT_PYTHON
          if [[ -z $_is_pipx_default ]]; then
            ${lib.optionalString use_rye_p ''
          export PIPX_DEFAULT_PYTHON="$(readlink -f $(${global_python_path} | jq -r '[.[] | select(.name | contains("${cmdp.global}"))].[0].path'))"
        ''}
            ${lib.optionalString (use_rye_p == false) ''
          export PIPX_DEFAULT_PYTHON="$(readlink -f $(${global_python_path})/bin/python)"
        ''}
          fi
          command pipx "$@"
          if [[ -z $_is_pipx_default ]]; then
            unset PIPX_DEFAULT_PYTHON
          fi
        };
        if ! builtin type _pipx >/dev/null 2>&1; then
          autoload -Uz _pipx
        fi
        if [[ -z "''${_comps[_pipx]}" ]]; then
          _comps[pipx]=_pipx
        fi
      '';
      # nushell.cmpFiles = ["${config.dotfiles.configDir}/pipx/pipx-completions.nu"];
      nushell.rcInit = lib.optionalString (global_python_path != "") ''
        export def --wrapped pipx [...rest: string] {
            if ($env | get --ignore-errors PIPX_DEFAULT_PYTHON | is-empty) {
                ${lib.optionalString use_rye_p ''
          let pipx_default_python = (${global_python_path} | from json | where ($it.name | str contains "${cmdp.global}") | get path | first | readlink -f $in)
        ''}
                ${lib.optionalString (use_rye_p == false) ''
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
  };
}
