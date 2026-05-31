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
  imports = modules "${root}/nix";

  perSystem =
    { system, ... }:
    {
      legacyPackages.homeConfigurations.test = self.my.mkhome {
        inherit system withSystem self;
        overlays = [ self.overlays.python ];
      };
    };
}
