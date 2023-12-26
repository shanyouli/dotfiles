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
  cfg = cfm.dev.cc;
in {
  options.modules.dev.cc = {
    enable = mkEnableOption "Whether to c/c++ dev";
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs.unstable;
      [
        clang
        # gcc
        cmake
        llvmPackages.libcxx
      ]
      ++ optionals stdenvNoCC.isLinux [bear gdb];
  };
}
