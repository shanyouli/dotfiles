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
    user.packages = [pkgs.direnv pkgs.nix-direnv];
    modules.shell.rcInit = ''_cache direnv hook zsh'';
    modules.editor.vscode.extensions = [pkgs.vscode-extensions.mkhl.direnv];
    home.configFile = mkMerge [
      {
        "direnv/direnvrc".text = ''
          source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
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
        cfg.stdlib))
    ];
  };
}
