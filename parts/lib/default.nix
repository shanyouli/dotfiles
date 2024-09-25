{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix {
      inherit lib;
      self = {};
    };
  };

  mylib = makeExtensible (self:
    with self;
      mapModules ./.
      (file: import file {inherit self lib inputs pkgs;}));

  mylibs = lib.extend (_self: _super: {
    my = mylib.extend (_sself: ssuper: foldr (a: b: a // b) {} (attrValues ssuper));
    inherit (inputs.home-manager.lib) hm;
  });
in {
  perSystem._module.args.lib = mylibs;

  flake.lib = mylibs;
}
