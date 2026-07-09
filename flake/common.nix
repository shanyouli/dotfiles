{
  inputs,
  self,
  withSystem,
  ...
}:
let
  root = ../.;
  inherit (inputs.nixpkgs.lib)
    filterAttrs
    mapAttrsToList
    hasSuffix
    hasPrefix
    ;
  filterFn =
    path:
    filterAttrs (
      name: type:
      (type == "directory" && (builtins.pathExists "${path}/${name}/default.nix"))
      || (type == "regular" && hasSuffix ".nix" name && name != "default.nix" && !(hasPrefix "_" name))
    ) (builtins.readDir path);
  modules = path: mapAttrsToList (name: _: "${path}/${name}") (filterFn path);
in
{
  imports = (modules "${root}/nix") ++ [ inputs.home-manager.flakeModules.home-manager ];
  flake.homeConfigurations = {
    "test@aarch64-darwin" = self.my.mkhome {
      inherit withSystem self;
      system = "aarch64-darwin";
      overlays = [ self.overlays.python ];
    };
    "test@x86_64-darwin" = self.my.mkhome {
      inherit withSystem self;
      system = "x86_64-darwin";
      overlays = [ self.overlays.python ];
    };
    "test@x86_64-linux" = self.my.mkhome {
      inherit withSystem self;
      system = "x86_64-linux";
      overlays = [ self.overlays.python ];
    };
    "test@aarch64-linux" = self.my.mkhome {
      inherit withSystem self;
      system = "aarch64-linux";
      overlays = [ self.overlays.python ];
    };
  };
  # perSystem =
  #   { system, ... }:
  #   {

  #     legacyPackages.homeConfigurations.test = self.my.mkhome {
  #       inherit system withSystem self;
  #       overlays = [ self.overlays.python ];
  #     };
  #   };
}
