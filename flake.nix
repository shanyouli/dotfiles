{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "darwin-stable";

    # 需要同步的 flake
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nurpkgs.url = "github:shanyouli/nur-packages/stable";
    nurpkgs.inputs.nixpkgs.follows = "nixpkgs";
    nurpkgs.inputs.nixpkgs-stable.follows = "nixos-stable";
    nurpkgs.inputs.flake-utils.follows = "flake-utils";
    nurpkgs.inputs.flake-compat.follows = "flake-compat";
    nurpkgs.inputs.flake-parts.follows = "flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {
        withSystem,
        self,
        ...
      }: {
        debug = true;
        systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
        imports = [
          ./parts/lib
          ./parts/vars
          ./parts/overlays
          ./parts/pkgs
          ./parts/home-modules.nix
        ];

        perSystem = {
          pkgs,
          system,
          ...
        }: {
          legacyPackages.homeConfigurations.test = self.lib.my.mkhome {
            inherit system withSystem self;
            modules = [(self.lib.my.relativeToRoot "hosts/test/home-manager.nix")
                       {
                         nixpkgs.overlays = [self.overlays.python];
                       }
                      ];
          };
        };

        flake = {
          # homeConfigurations 自定义配置
          # homeConfigurations  = {
          #   "lyeli" = self.lib.my.mkhome {
          #     inherit withSystem self;
          #     system = "x86_64-linux";
          #     modules = [(self.lib.my.relativeToRoot "hosts/test/home-manager.nix")];
          #   };
          # };
        };
      }
    );
}
