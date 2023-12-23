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
      extensions = with pkgs.unstable.vscode-extensions; let
        cpp =
          if pkgs.stdenvNoCC.isLinux
          then ms-vscode.cpptools
          else
            pkgs.unstable.vscode-utils.extensionFromVscodeMarketplace {
              name = "cpptools";
              publisher = "ms-vscode";
              version = "1.18.5";
              sha256 = "sha256-Ke0PCq9vJtqi1keqzTbVlils8g5UVvMw14b8Y0Rb49Y=";
            };
      in
        [
          vscodevim.vim
          jnoortheen.nix-ide
          formulahendry.code-runner
        ]
        ++ optionals cfm.shell.direnv.enable [
          mkhl.direnv
        ]
        ++ optionals cfm.dev.cc.enable [
          cpp
        ];
      userSettings = {
        "nix.serverPath" = "rnix-lsp";
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "alejandra";
      };
    };
  };
}
