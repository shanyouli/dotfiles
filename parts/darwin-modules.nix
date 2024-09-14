{self, ...}: let
  inherit (self.lib.my) relativeToRoot mapModulesRec';
in {
  flake.darwinModules = let
    basemodule = [(relativeToRoot "modules/optionals/os.nix")];
    ownermodule = mapModulesRec' (relativeToRoot "modules/darwin") import;
  in {
    base = {...}: {imports = basemodule;};
    owner = {...}: {imports = ownermodule;};
    default = {...}: {imports = basemodule ++ ownermodule;};
  };
  perSystem = {
    self',
    inputs',
    pkgs,
    ...
  }: {
    packages.darwin-rebuild = inputs'.darwin.packages.default;
    apps.init-darwin.program = pkgs.writeScriptBin "init-darwin" ''
      #!${pkgs.lib.getExe pkgs.nushell}
      print $env.FILE_PWD
      let uname_info = uname
      let arch = if (($uname_info | get machine | str downcase) == "arm64") {
        "aarch64"
      } else {
        "x86_64"
      }
      let systemos = "darwin"

      let cmdbin = "${self'.packages.darwin-rebuild}/bin/darwin-rebuild"

      let common_options = [
        --impure,
        --show-trace,
        -L
      ]
      # ${self} ==> .;
      # test home-manager can build
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
