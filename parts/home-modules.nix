{self, ...}: let
  inherit (self.lib.my) relativeToRoot mapModulesRec';
in {
  flake.homeModules = let
    basemodule = [(relativeToRoot "modules/optionals/hm.nix")];
    commonModule = mapModulesRec' (relativeToRoot "modules/shared") import;
  in {
    base = {...}: {imports = basemodule;};
    common = {...}: {imports = commonModule;};
    default = {...}: {imports = basemodule ++ commonModule;};
  };
  perSystem = {
    self',
    inputs',
    pkgs,
    ...
  }: {
    packages.home-manager = inputs'.home-manager.packages.default;
    apps.init-home.program = pkgs.writeScriptBin "init-home" ''
      #!${pkgs.lib.getExe pkgs.nushell}

      let hmbin = "${self'.packages.home-manager}/bin/home-manager"
      let common_options = [--impure, --extra-experimental-features, "nix-command flakes", --no-write-lock-file ]
      # test home-manager can build
      def --wrapped test [...rest] {
        ^$hmbin ...$common_options build --flake "${self}#test" -b backup ...$rest
      }

      def --wrapped main [
        subcmd: string = "test" # subCommand
        --host: string  # host 名称
        ...rest # 其他额外参数
      ] {
        if ($subcmd == "test") {
          test ...$rest
        } else if ($subcmd == "help") {
          ^$hmbin --help
        } else if ($subcmd in ["build" "switch"]) {
          if ($host == "") {
            ^$hmbin ...$common_options $subcmd --flake $'"${self}#($env.USER)"' -b backup ...$rest
          } else {
            ^$hmbin ...$common_options $subcmd --flake $'"${self}#($host)"' -b backup ...$rest
          }
        } else {
          ^$hmbin ...$common_options $subcmd ...$rest
        }
      }
    '';
  };
}
