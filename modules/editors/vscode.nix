{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.editors.vscode;
in {
  options.modules.editors.vscode = {
    enable = mkBoolOpt false;
    basePkg = mkOption {
      type = with types; nullOr (either str package);
      default = null;
      apply = v: let
        pkglist = with pkgs; [ vscode vscodium unstable.vscode unstable.vscodium ];
      in if elem v pkglist
         then v
         else if elem v [ "vscode" "code" ]
         then pkgs.vscode
         else pkgs.vscodium;
      description = ''Using codium or code !'';
    };
    pkg = mkPkgReadOpt "The vscode";
  };

  config = mkIf cfg.enable {
    modules.editors.vscode.pkg = pkgs.symlinkJoin {
      name = "my-vscodium-${cfg.basePkg.version}";
      paths = [ cfg.basePkg ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/codium \
          --add-flags " --user-data-dir ${xdgConfig}/vscode --extensions-dir ${xdgData}/vscode"
      '';
    };
    user.packages = [ cfg.pkg ];
  };
}
