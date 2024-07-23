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
    modules.shell.python.finalPkg = pkgs.python3.withPackages cfg.extraPkgs;
    user.packages = [
      cfg.finalPkg
      pkgs.pipx # A better python command line installation tool
    ];
    modules.shell = {
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
      rcInit = ''
        pipx() {
          if [[ -z "''${_comps[_pipx]}" ]]; then
            _comps[pipx]=_pipx
          fi
          if (( $+commands[asdf] )) ; then
            export PIPX_DEFAULT_PYTHON=$(asdf which python)
          elif (( $+commands[mise])) ; then
            export PIPX_DEFAULT_PYTHON=$(mise where python@3.11)/bin/python
          fi
          command pipx "$@"
          unset PIPX_DEFAULT_PYTHON
        };
        if ! builtin type _pipx >/dev/null 2>&1; then
          autoload -Uz _pipx
        fi
        if [[ -z "''${_comps[_pipx]}" ]]; then
          _comps[pipx]=_pipx
        fi
      '';
      # nushell.cmpFiles = ["${config.dotfiles.configDir}/pipx/pipx-completions.nu"];
      nushell.rcInit = ''
        export def --wrapped pipx [...rest: string] {
            let pipx_default_python = if (not (which mise | is-empty)) {
                [(mise where python@3.11), "bin", "python"] | path join
                # ^mise which python
            } else if (not (which asdf | is-empty)) {
                [(asdf where python 3.11.9), "bin", "python"] | path join
            } else {
                ""
            }
            if $pipx_default_python == "" {
                ^pipx ...$rest
            } else {
                with-env {PIPX_DEFAULT_PYTHON: $pipx_default_python } {
                    ^pipx ...$rest
                }
            }
        }
      '';
    };
  };
}
