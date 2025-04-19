{ inputs, ... }:
let
  inherit (builtins) intersectAttrs functionArgs;
  # inherit (builtins) mapAttrs intersectAttrs functionArgs getEnv fromJSON;
  inherit (inputs.nixpkgs) lib;
  inherit (lib)
    attrValues
    foldr
    foldl
    makeExtensible
    ;

  # mapModules gets special treatment because it's needed early!
  inherit (attrs) attrsToList mergeAttrs';
  inherit (modules) mapModules;
  attrs = import ./attrs.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib attrs; };

  /*
    Given an attrset of nix module partials, returns it as a sorted list of
    NameValuePairs according to its callPackage-style dependencies from the
    rest of the list.

    sortLibsByDeps :: AttrSet -> [ AttrSet ... ]

    Example:
      sortLibsByDeps { libA = { libB, ... }: {}; libB = { ... }: { [...] }; }
      => [ { libB = {...}: [...]; } { libA = { libB, ...}: [...]; } ]
  */
  sortLibsByDeps = modules: modules;

  # TODO
  # let
  #   dependsOn = a: b:
  #     elem a (attrByPath b [] deps);
  #   maybeSortedAttrs = toposort dependsOn (diskoLib.deviceList devices);
  # in
  #   if (hasAttr "cycle" maybeSortedAttrs) then
  #     abort "detected a cycle in your disk setup: ${maybeSortedAttrs.cycle}"
  #   else
  #     maybeSortedAttrs.result;

  # I embrace the callPackage pattern for lib/*.nix modules. I.e. Their
  # arguments are dynamically passed as they are loaded, drawn from a running
  # list of loaded lib/*.nix modules (plus the nixpkgs 'lib' passed to this
  # module and the whole set altogether).
  libConcat = a: b: a // { ${b.name} = b.value (intersectAttrs (functionArgs b.value) a); };
in
# FIXME: Lexicographical loading can cause race conditions. Sort them?
# libModules = sortLibsByDeps (mapModules ./. import);
# libs = foldl libConcat { inherit lib inputs; self = libs; } (attrsToList libModules);
# my = makeExtensible (self:
#   with self;
#     mapModules ./.
#     (file: import file {inherit self lib inputs attrs;}));
# libs = lib.extend (_self: _super: {
#   my = my.extend (_sself: ssuper: foldr (a: b: a // b) {} (attrValues ssuper));
#   inherit (inputs.home-manager.lib) hm;
# });
# libs = mapModules ./. (file: import file {inherit lib inputs attrs;});
{
  # perSystem._module.args.lib = mys;

  # flake.my = libs // (mergeAttrs' (attrValues libs));
  flake = {
    lib =
      let
        libModules = sortLibsByDeps (mapModules ./. import);
        libs = foldl libConcat {
          inherit lib inputs;
          self = libs;
        } (attrsToList libModules);
      in
      libs // (mergeAttrs' (attrValues libs));
    my =
      let
        libs = makeExtensible (
          self: with self; mapModules ./. (file: import file { inherit lib inputs attrs; })
        );
      in
      # libs = mapModules ./. (file: import file {inherit lib inputs attrs;});
      libs.extend (_self: prev: foldr (a: b: a // b) { } (attrValues prev));
  };
}
