{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.direnv;
in {
  options.modules.shell.direnv = {
    enable = mkBoolOpt false;
    stdlib = with types; mkOpt' (attrsOf (oneOf [str path setType])) {} "Libs used by direnv";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [pkgs.direnv pkgs.nix-direnv];
      programs.bash.initExtra = ''
        eval "$(direnv hook bash)"
      '';
      configFile = mkMerge [
        {
          "direnv/direnvrc".text = ''
            source ${pkgs.unstable.nix-direnv}/share/nix-direnv/direnvrc
          '';
        }
        (mkIf (cfg.stdlib != {}) (concatMapAttrs (name: value: (
            let
              newname =
                if hasPrefix "use_" name
                then name
                else "use_" + name;
              newvalue =
                if (builtins.typeOf value) == "set"
                then value.outPath
                else value;
            in {"direnv/lib/${newname}.sh".source = newvalue;}
          ))
          (filterAttrs (_n: v: !(builtins.isNull v)) cfg.stdlib)))
      ];
    };
    modules = {
      app.editor.vscode.extensions = [pkgs.unstable.vscode-extensions.mkhl.direnv];
      shell = {
        zsh = {
          rcInit = ''_cache -v ${pkgs.direnv.version} direnv hook zsh'';
          pluginFiles = ["direnv"];
        };
        nushell.rcInit = ''
          $env.config = ($env | default {} config).config
          $env.config = ($env.config | default {} hooks)
          $env.config = (
              $env.config | upsert hooks (
                  $env.config.hooks | upsert pre_prompt (
                      $env.config.hooks
                      | get -i pre_prompt
                      | default []
                      | append { || ^direnv export json | from json | default {} | load-env}
                      )))
        '';
      };
    };
  };
}
