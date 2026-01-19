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
  cfg = config.modules.shell.direnv;
in
{
  options.modules.shell.direnv = {
    enable = mkBoolOpt false;
    package = mkPackageOption pkgs "nix-direnv" { };
    stdlib =
      with types;
      mkOpt' (attrsOf (oneOf [
        str
        path
        setType
      ])) { } "Libs used by direnv";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        pkgs.direnv
        cfg.package
      ];
      programs.bash.initExtra = ''
        eval "$(direnv hook bash)"
      '';
      configFile = mkMerge [
        {
          "direnv/direnvrc".text = ''
            #!/usr/bin/env bash
            source ${cfg.package}/share/nix-direnv/direnvrc
            # Hum-readable directories @see https://github.com/direnv/direnv/wiki/Customizing-cache-location
            : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
            declare -A direnv_layout_dirs
            direnv_layout_dirs() {
              local hash path
              echo "''${direnv_layout_dirs[$PWD]:=$(
                hash="$(sha1sum - <<< "$PWD" | head -c40)"
                path="''${PWD//[^a-zA-Z0-9]/-}"
                echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
              )}"
            }
          '';
        }
        (mkIf (cfg.stdlib != { }) (
          concatMapAttrs (
            name: value:
            (
              let
                newname = if hasPrefix "use_" name then name else "use_" + name;
                newvalue = if (builtins.typeOf value) == "set" then value.outPath else value;
              in
              {
                "direnv/lib/${newname}.sh".source = newvalue;
              }
            )
          ) (filterAttrs (_n: v: !(builtins.isNull v)) cfg.stdlib)
        ))
      ];
    };
    modules = {
      app.editor.vscode.extensions = [ pkgs.unstable.vscode-extensions.mkhl.direnv ];
      shell = {
        zsh = {
          rcInit = ''_cache -v ${pkgs.direnv.version} direnv hook zsh'';
          pluginFiles = [ "direnv" ];
        };
        fish.rcInit = ''_cache -v${pkgs.direnv.version} direnv hook fish'';
        nushell.rcInit = ''
          $env.config = ($env | default {} config).config
          $env.config = ($env.config | default {} hooks)
          $env.config = (
              $env.config | upsert hooks (
                  $env.config.hooks | upsert pre_prompt (
                      $env.config.hooks
                      | get -o pre_prompt
                      | default []
                      | append { || ^direnv export json | from json | default {} | load-env}
                      )))
        '';
      };
    };
  };
}
