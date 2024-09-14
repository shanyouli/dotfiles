{self, ...}: let
  inherit (self.lib.my) relativeToRoot mapModulesRec';
in {
  flake.nixosModules = let
    baseMD = [(relativeToRoot "modules/optionals/os.nix")];
    hardwareMD = mapModulesRec' (relativeToRoot "modules/hardware") import;
    commonMD = mapModulesRec' (relativeToRoot "modules/nixos") import;
  in rec {
    base = {...}: {imports = baseMD;};
    hardware = {...}: {imports = hardwareMD;};
    common = {...}: {imports = commonMD;};
    # owner = hardware ++ common; # 暂时没有使用 hardware 模块
    owner = {...}: {imports = commonMD ++ self.lib.optionals false hardwareMD;};
    default = {...}: {imports = [base owner self.homeModules.common];};
  };
  perSystem = {pkgs, ...}: {
    apps.init-nixos.program = pkgs.writeScriptBin "init-darwin" ''
      #!${pkgs.lib.getExe pkgs.nushell}
      print $env.FILE_PWD
      let uname_info = uname
      let arch = if (($uname_info | get machine | str downcase) == "arm64") {
        "aarch64"
      } else {
        "x86_64"
      }
      let systemos = "linux"

      let cmdbin = "nixos-rebuild"

      let common_options = [
        --impure,
        # --substituters,
        # "https://shanyouli.cachix.org",
        --show-trace,
        -L
      ]
      # ${self} ==> .;
      # test nixos can build
      def --wrapped test [...rest] {
        ^$cmdbin ...$common_options build --flake $'"${self}#test@($arch)-($systemos)"' ...$rest
      }

      def --wrapped main [
        subcmd: string = "test" # subCommand
        --host: string  # host 名称
        ...rest # 其他额外参数
      ] {
        if ($subcmd == "test") {
          test ...$rest
        } else if ($subcmd == "help") {
          ^$cmdbin --help
        } else if ($subcmd in ["build", "switch"]) {
          if ($host == null) {
            ^$cmdbin ...$common_options $subcmd --flake $'"${self}#($env.USER)@($arch)-($systemos)"' ...$rest
          } else {
            ^$cmdbin ...$common_options $subcmd --flake $'"${self}#($host)"' ...$rest
          }
        } else {
          ^$cmdbin ...$common_options $subcmd ...$rest
        }
      }

    '';
  };
}
