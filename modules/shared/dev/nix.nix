{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.dev.nix;
in {
  options.modules.dev.nix = {
    enable = mkEnableOption "Whether to Nix Language";
    lspPkg = mkPkgOpt pkgs.nil "Nix LSP pkg";
    fmtPkg = mkPkgOpt pkgs.alejandra "Nix Format";
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      cfg.lspPkg
      cfg.fmtPkg
      nix-init
      nurl # better nix-prefetch-xxx
    ];
    home.configFile."nix-init/config.toml".text = ''
      maintainers = [ "${config.user.name}" ]
      nixpkgs = "<nixpkgs>"
    '';
    modules.editor.emacs.doom.confInit = ''
      (setopt my-nix-lsp-cmd "${cfg.lspPkg.pname}")
    '';
  };
}
