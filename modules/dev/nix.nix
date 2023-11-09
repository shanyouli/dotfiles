{ config, optional, pkgs, lib, ...}:
with lib;
with lib.my;
let cfg = config.modules.dev.nix;
in {
  options.modules.dev.nix = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs.unstable;[ rnix-lsp nixfmt ];
    # rnix-lsp so slow running in emacs-lsp
    # modules.editors.emacs.doom.confInit = ''
    #   (add-hook 'nix-mode-hook #'lsp!)
    # '';
  };
}
