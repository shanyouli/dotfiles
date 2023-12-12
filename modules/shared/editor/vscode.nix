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
  cfg = cfm.editor.vscode;
in {
  options.modules.editor.vscode = {
    enable = mkEnableOption "Whether using vscode";
  };
  config = mkIf cfg.enable {
    my.programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscode;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.unstable.vscode-extensions; [
        vscodevim.vim
        jnoortheen.nix-ide
      ];
      userSettings = {
        "nix.serverPath" = "rnix-lsp";
        "nix.enableLanguageServer" = trie;
        "nix.formatterPath" = "alejandra";
      };
    };
  };
}
