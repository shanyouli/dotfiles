{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.dev.nix;
in
{
  options.modules.dev.nix = {
    enable = mkEnableOption "Whether to Nix Language";
    lspPkg = mkPackageOption pkgs "nil" { };
    fmtPkg = mkPackageOption pkgs "nixfmt-rfc-style" { };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.lspPkg
      cfg.fmtPkg
      nix-init
      nurl # better nix-prefetch-xxx
      pkgs.unstable.manix # support nix-darwin
    ];
    home.configFile."nix-init/config.toml".text = ''
      maintainers = [ "${my.user}" ]
      nixpkgs = "<nixpkgs>"
    '';
    modules.app.editor.emacs.doom.confInit = ''
      (setopt my-nix-lsp-cmd "${cfg.lspPkg.pname}")
    '';
  };
}
