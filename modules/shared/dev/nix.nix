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
    lspPkg = mkPkgOpt pkgs.unstable.rnix-lsp "Nix LSP pkg";
    fmtPkg = mkPkgOpt pkgs.unstable.alejandra "Nix Format";
  };
  config = mkIf cfg.enable {
    my.user.packages = with pkgs.unstable; [
      cfg.lspPkg
      cfg.fmtPkg
      nix-init
      nurl # better nix-prefetch-xxx
    ];
    my.hm.configFile."nix-init/config.toml".text = ''
      maintainers = [ "${config.my.username}" ]
      nixpkgs = "<nixpkgs>"
    '';
  };
}
