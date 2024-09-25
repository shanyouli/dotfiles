{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  attrs = import ./attrs.nix {inherit lib;};
  modules = import ./modules.nix {inherit lib attrs;};

  mylib = makeExtensible (self:
    with self;
      mapModules ./.
      (file: import file {inherit self lib inputs attrs;}));

  mylibs = lib.extend (_self: _super: {
    my = mylib.extend (_sself: ssuper: foldr (a: b: a // b) {} (attrValues ssuper));
    inherit (inputs.home-manager.lib) hm;
  });
in {
  perSystem._module.args.lib = mylibs;

  flake.lib = mylibs;
}
