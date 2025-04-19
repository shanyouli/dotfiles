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
  cfg = cfm.app.editor.vscode;
in
{
  options.modules.app.editor.vscode = {
    enable = mkEnableOption "Whether using vscode";
    extensions = mkOpt' (types.listOf types.package) [ ] "VScode extensions";
  };
  config = mkIf cfg.enable {
    modules.app.editor.vscode.extensions = with pkgs.unstable.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide
      formulahendry.code-runner
      arrterian.nix-env-selector
    ];
    home.programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default = {
        inherit (cfg) extensions;
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        userSettings = {
          "nix.serverPath" = "nil";
          "nix.enableLanguageServer" = true;
          "nix.formatterPath" = "nixfmt";
          "security.workspace.trust.enabled" = false; # 禁用全局工作区询问是否信任
        };
      };
    };
  };
}
