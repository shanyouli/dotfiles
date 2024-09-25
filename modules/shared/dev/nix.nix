{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfm = config.modules;
  cfg = cfm.dev.nix;
in {
  options.modules.dev.nix = {
    enable = mkEnableOption "Whether to Nix Language";
    lspPkg = mkPkgOpt pkgs.nil "Nix LSP pkg";
    fmtPkg = mkPkgOpt pkgs.alejandra "Nix Format";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.lspPkg
      cfg.fmtPkg
      nix-init
      nurl # better nix-prefetch-xxx
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
