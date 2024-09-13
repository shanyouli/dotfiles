{self, ...}: let
  inherit (self.lib.my) relativeToRoot mapModulesRec';
in {
  flake.nixosModules = rec {
    base = [(relativeToRoot "modules/optionals/os.nix")];
    hardware = mapModulesRec' (relativeToRoot "modules/hardware");
    common = mapModulesRec' (relativeToRoot "modules/nixos");
    # owner = hardware ++ common; # 暂时没有使用 hardware 模块
    owner = common;
    defautl = base ++ self.homeModules.common ++ owner;
  };
  perSystem = {
    self',
    inputs',
    pkgs,
    ...
  }: {
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
