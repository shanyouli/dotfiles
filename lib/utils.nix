{
  self,
  lib,
  ...
}:
# copy from https://github.com/wiltaylor/dotfiles/blob/e0217a4042fb2c226f34f67d5cc90c3cf1e4364c/lib/default.nix
let
  inherit (builtins) elem foldl' attrValues typeOf elemAt head tryEval filter getAttr attrNames;
  inherit (self.modules) mapModulesRec';
  defaultSystems = ["aarch64-linux" "aarch64-darwin" "x86_64-darwin" "x86_64-linux"];
  darwinSystem = ["x86_64-darwin" "aarch64-darwin"];
  isDarwin = system: elem system darwinSystem;
in rec {
  inherit defaultSystems darwinSystem;
  # Package names to exclude from search
  # Use to exclude packages that cause errors during search.
  searchBlackList = ["hyper-haskell-server-with-packages"];

  # Taken from flake-utils
  # List of all systems defined in nixpkgs
  # Keep in sync with nixpkgs wit the following command:
  # $ nix-instantiate --json --eval --expr "with import <nixpkgs> {}; lib.platforms.all" | jq
  allSystems = [
    "aarch64-linux"
    "armv5tel-linux"
    "armv6l-linux"
    "armv7a-linux"
    "armv7l-linux"
    "mipsel-linux"
    "i686-cygwin"
    "i686-freebsd"
    "i686-linux"
    "i686-netbsd"
    "i686-openbsd"
    "x86_64-cygwin"
    "x86_64-freebsd"
    "x86_64-linux"
    "x86_64-netbsd"
    "x86_64-openbsd"
    "x86_64-solaris"
    "x86_64-darwin"
    "i686-darwin"
    "aarch64-darwin"
    "armv7a-darwin"
    "x86_64-windows"
    "i686-windows"
    "wasm64-wasi"
    "wasm32-wasi"
    "x86_64-redox"
    "powerpc64le-linux"
    "riscv32-linux"
    "riscv64-linux"
    "arm-none"
    "armv6l-none"
    "aarch64-none"
    "avr-none"
    "i686-none"
    "x86_64-none"
    "powerpc-none"
    "msp430-none"
    "riscv64-none"
    "riscv32-none"
    "vc4-none"
    "js-ghcjs"
    "aarch64-genode"
    "x86_64-genode"
  ];
  evalMods = {
    allPkgs,
    systems ? defaultSystems,
    modules,
    args ? {},
  }:
    withSystems systems (sys: let
      pkgs = allPkgs."${sys}";
    in
      pkgs.lib.evalModules {
        inherit modules;
        specialArgs = {inherit pkgs;} // args;
      });
  mkPkg = {
    nixpkgs,
    system ? "x86_64-linux",
    cfg ? {},
    overlays ? {},
    extraOverlays ? [],
  }: let
    pkgs =
      if (typeOf nixpkgs) == "list"
      then
        if isDarwin system
        then elemAt nixpkgs 1
        else head nixpkgs
      else nixpkgs;
  in
    import pkgs {
      inherit system;
      config = cfg;
      overlays = (attrValues overlays) ++ extraOverlays;
    };
  mkPkgs = {
    nixpkgs,
    systems ? defaultSystems,
    cfg ? {},
    overlays ? {},
  }:
    withSystems systems (system:
      mkPkg {
        inherit cfg overlays nixpkgs;
        system = system;
      });

  mkOverlays = {
    allPkgs,
    systems ? defaultSystems,
    overlayFunc,
  }:
    withSystems systems
    (sys: let pkgs = allPkgs."${sys}"; in overlayFunc sys pkgs);

  withDefaultSystems = withSystems defaultSystems;
  withSystems = systems: f:
    foldl' (cur: nxt: let ret = {"${nxt}" = f nxt;}; in cur // ret) {}
    systems;

  LoadRepoSecrets = path: let
    data = tryEval (import path);
  in
    if data.success
    then data.value
    else {};
  mkSystem = {
    name,
    os,
    allPkgs,
    system,
    baseModules ? [{nixpkgs.config.allowUnfree = true;}],
    extraModules ? [],
    specialArgs ? {},
  }: let
    useDarwin = isDarwin system;
    sysFunc =
      if useDarwin
      then os.lib.darwinSystem
      else os.lib.nixosSystem;
    defaultModule =
      [
        ({
            nixpkgs.pkgs = allPkgs."${system}";
            networking.hostName = "${name}";
          }
          // (
            if useDarwin
            then {}
            else {
              system.stateVersion = "23.11";
              boot.readOnlyNixStore = true;
              # Currently doesn't work in nix-darwin
              # https://discourse.nixos.org/t/man-k-apropos-return-nothing-appropriate/15464
              documentation.man.generateCaches = true;
            }
          ))
      ]
      ++ baseModules
      ++ (mapModulesRec' (toString ../modules/shared) import)
      ++ (mapModulesRec' (
          if useDarwin
          then toString ../modules/darwin
          else toString ../modules/nixos
        )
        import);
  in
    sysFunc {
      inherit system specialArgs;
      modules = defaultModule ++ extraModules;
    };
  # @see https://github.com/kclejeune/system/blob/9c3b4222e1f4a48d392d0bba244740481160f819/flake.nix#L129
  mkChecks = {
    self,
    arch,
    os,
    username ? "lyeli",
  }: {
    "${arch}-${os}" = {
      "${username}_${os}" = let
        osConfig =
          if os == "darwin"
          then self.darwinConfigurations
          else self.nixosConfigurations;
      in
        osConfig."${username}@${arch}-${os}".config.system.build.toplevel;
      devShell = self.devShells."${arch}-${os}".default;
      # TODO:
      # "${username}_home" =
      #     self.homeConfigurations."${username}@${arch}-${os}".activationPackage;
    };
  };

  mkSearchablePackages = allPkgs: let
    filterBadPkgs = pkgs: let
      badList =
        filter
        (a: let res = tryEval (getAttr a pkgs); in (res.success == false))
        (attrNames pkgs)
        ++ searchBlackList;
    in
      removeAttrs pkgs badList;
  in
    foldl'
    (l: r: let ret = {"${r}" = filterBadPkgs allPkgs."${r}";}; in l // ret)
    {} (attrNames allPkgs);
}
