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
    extensions = mkOpt' (types.listOf types.package) [] "VScode extensions";
  };
  config = mkIf cfg.enable {
    modules.editor.vscode.extensions = with pkgs.unstable.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide
      formulahendry.code-runner
      arrterian.nix-env-selector
    ];
    home.programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscode;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = cfg.extensions;
      userSettings = {
        "nix.serverPath" = "rnix-lsp";
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "alejandra";
        "security.workspace.trust.enabled" = false; # 禁用全局工作区询问是否信任
      };
    };
  };
}
