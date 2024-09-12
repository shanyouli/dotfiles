{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    # nixos-flake.url = "github:srid/nixos-flake";
  };

  outputs = inputs @ {self, ...}: let
    lib = inputs.nixpkgs.lib.extend (self: super: {
      my = import ./lib {
        inherit inputs;
        lib = self;
      };
    });
    genSpecialArgs = system: let
      lib = inputs.nixpkgs.lib.extend (self: super: {
        my = import ./lib {
          inherit inputs;
          lib = self;
        };
        var = import ./vars {
          inherit inputs;
          lib = inputs.nixpkgs.lib;
          system = system;
        };
        hm = inputs.home-manager.lib.hm;
      });
    in {inherit inputs lib self;};
    isDarwin = system: builtins.elem system lib.platforms.darwin;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      imports = [];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        # TODO: Change username
        myUserName = "lyeli";
      in {
        legacyPackages.homeConfigurations.${myUserName} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = genSpecialArgs system;
          modules = [
            ({pkgs, ...}: {
              imports = [self.homeModules.default];
              home.username = myUserName;
              home.homeDirectory = "/${
                if pkgs.stdenv.isDarwin
                then "Users"
                else "home"
              }/${myUserName}";
              home.stateVersion = "24.11";
              nix.settings.use-xdg-base-directories = true;
              nix.enable = true;
              nix.package = pkgs.nix;
            })
          ];
        };

        # Make our overlay available to the devShell
        _module.args = {
          pkgs = let
            mypkgs =
              if isDarwin system
              then inputs.darwin-stable
              else inputs.nixos-stable;
          in
            import mypkgs {
              inherit system;
              overlays = [];
            };
          lib = inputs.nixpkgs.lib.extend (self: super: {
            my = import ./lib {
              inherit inputs;
              lib = self;
            };
            var = import ./vars {
              inherit inputs;
              lib = inputs.nixpkgs.lib;
              system = system;
            };
            hm = inputs.home-manager.lib.hm;
          });
        };
      };

      flake = {
        # All home-manager configurations are kept here.
        homeModules.default = {pkgs, ...}: {
          imports = [];
          programs = {
            git.enable = true;
            starship.enable = true;
            bash.enable = true;
          };
        };
      };
    };
}
