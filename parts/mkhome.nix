{
  withSystem,
  self,
  ...
}: let
  mkHome = {
    system ? "x86_64-linux",
    nixpkgs ? null,
    overlays ? [],
    config ? {},
    modules ? [],
  }:
    withSystem system (
      {
        lib,
        pkgs,
        system,
        myvars,
        ...
      }:
        self.inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = let
            isUpPkgs = ! (builtins.isNull nixpkgs);
            mypkgs =
              if isUpPkgs
              then nixpkgs
              else
                (
                  if pkgs.stdaenvNoCC.isDarwin
                  then self.inputs.darwin-stable
                  else self.inputs.nixos-stable
                );
          in
            if (isUpPkgs || config != {} || overlays != [])
            then
              import mypkgs (lib.recursiveUpdate {
                  inherit system;
                  overlays = [self.overlay.default] ++ overlays;
                  config.allowUnfree = true;
                } {
                  inherit config;
                })
            else pkgs;
          extraSpecialArgs = {
            inherit self myvars;
            inherit (self) inputs lib;
          };
          modules = [] ++ self.homeModules.default ++ modules;
        }
    );
in {
  flake.homeConfigurations = {
    test = mkHome {
      modules = [(self.lib.my.relativeToRoot "hosts/test/home-manager.nix")];
    };
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

      # test home-manager can build
      def --wrapped test [...rest] {
        ^$hmbin --extra-experimental-features "nix-command flakes" build --flake "${self}#test" -b backup ...$rest
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
            ^$hmbin --extra-experimental-features "nix-command flakes" $subcmd --flake $'"${self}#($env.USER)"' -b backup ...$rest
          } else {
            ^$hmbin --extra-experimental-features "nix-command flakes" $subcmd --flake $'"${self}#($host)"' -b backup ...$rest
          }
        } else {
          ^$hmbin --extra-experimental-features "nix-command flakes" $subcmd ...$rest
        }
      }
    '';
  };
}
