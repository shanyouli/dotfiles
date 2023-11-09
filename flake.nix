# flake.nix --- the heart of my dotfiles
#
# Author:  Henrik Lissner <henrik@lissner.net>
# URL:     https://github.com/hlissner/dotfiles
# License: MIT
#
# Welcome to ground zero. Where the whole flake gets set up and all its modules
# are loaded.

{
  description = "A grossly incandescent nixos config.";

  inputs =
    {
      # Core dependencies.
      # Two inputs so I can track them separately at different rates.
      nixpkgs.url           = "https://mirrors.ustc.edu.cn/nix-channels/nixos-20.09/nixexprs.tar.xz";
      nixpkgs-unstable.url = "nixpkgs/master";
      home-manager.url   = "github:nix-community/home-manager/release-20.09";
      home-manager.inputs.nixpkgs.follows = "/nixpkgs";
      # Extras
      emacs-overlay.url  = "github:nix-community/emacs-overlay";
      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      inherit (lib) attrValues genAttrs attrNames recursiveUpdate;
      inherit (lib.my) mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;  # forgive me Stallman senpai
        config.android_sdk.accept_license = true;
        overlays = extraOverlays ++ (attrValues self.overlays);
      };
      pkgs  = mkPkgs nixpkgs [ self.overlay ];
      uPkgs = mkPkgs nixpkgs-unstable [];

      lib = nixpkgs.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
    in {
      lib = lib.my;

      overlay =
        final: prev: {
          unstable = uPkgs;
          # my = self.packages."${system}";
        } // import ./packages final prev;

      overlays =
        mapModules ./overlays import;

      packages."${system}" =
        let
          packages = self.overlay pkgs pkgs;
          overlays = lib.filterAttrs (n: v: n != "pkgs") self.overlays;
          overlayPkgs =
            genAttrs
              (attrNames overlays)
              (name: (overlays."${name}" pkgs pkgs)."${name}");
        in
        recursiveUpdate packages overlayPkgs;

      nixosModules =
        { dotfiles = import ./.;
        } // mapModulesRec ./modules import;

      nixosConfigurations =
        mapHosts ./hosts { inherit system; };
    };
}
