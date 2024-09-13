{inputs, ...}: let
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
      (file: import file {inherit self lib inputs;}));

  mylibs = lib.extend (self: super: {
    my = mylib.extend (sself: ssuper: foldr (a: b: a // b) {} (attrValues ssuper));
    hm = inputs.home-manager.lib.hm;
  });
in {
  perSystem._module.args.lib = mylibs;

  flake.lib = mylibs;
}
