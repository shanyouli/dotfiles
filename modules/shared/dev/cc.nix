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
  cfg = cfm.dev.cc;
in
{
  options.modules.dev.cc = {
    enable = mkEnableOption "Whether to c/c++ dev";
  };
  config = mkIf cfg.enable {
    # gcc
    home.packages =
      with pkgs;
      [
        cmake
        llvmPackages.libcxx
      ]
      ++ optionals stdenvNoCC.isLinux [
        bear
        gdb
        clang
      ];
    modules.app.editor.vscode.extensions =
      with pkgs.vscode-extensions;
      let
        cpp =
          if pkgs.stdenvNoCC.isLinux then
            ms-vscode.cpptools
          else
            pkgs.vscode-utils.extensionFromVscodeMarketplace {
              name = "cpptools";
              publisher = "ms-vscode";
              version = "1.18.5";
              sha256 = "sha256-Ke0PCq9vJtqi1keqzTbVlils8g5UVvMw14b8Y0Rb49Y=";
            };
      in
      [ cpp ];
  };
}
