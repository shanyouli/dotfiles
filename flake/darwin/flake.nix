{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nurpkgs = {
      url = "github:shanyouli/nur-packages/stable";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        git-hooks-nix.follows = "git-hooks-nix";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # 托管 homebrew 本体（钉死版本、自动迁移既有安装）；包声明仍走 nix-darwin 的 homebrew.*
    # 注：该项目只声明 brew-src 一个 input，不涉及 nixpkgs，因此无需 follows
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # nix-homebrew 声明式 taps（flake = false：当作仓库快照，不当作 flake）
    # key 名对应 Library/Taps 下的目录名，格式为 owner/homebrew-<repo>
    # 注：刻意不声明 homebrew-core / homebrew-cask，保留 API 模式让 formula/cask
    #     元数据自动更新（否则会触发 HOMEBREW_NO_INSTALL_FROM_API=1 并被 pin 死）
    homebrew-tap-buo = {
      url = "github:buo/homebrew-cask-upgrade";
      flake = false;
    };
    homebrew-tap-shanyouli = {
      url = "github:shanyouli/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, self, ... }:
      let
        inherit (inputs) home-manager darwin nixpkgs-stable;
        lib = inputs.nixpkgs.lib;

        # mkdarwin builds a nix-darwin system configuration. It is inlined
        # here (rather than selected at runtime via a platform guard) so the
        # darwin flake always exposes it regardless of evaluation order.
        mkdarwin =
          {
            name ? "localhost",
            system ? "aarch64-darwin",
            nixpkgs ? null,
            overlays ? [ ],
            config ? { },
            modules ? [ ],
          }:
          withSystem system (
            {
              pkgs,
              system,
              my,
              ...
            }:
            darwin.lib.darwinSystem (
              let
                usePkgs = my.mkUsePkgs {
                  inherit
                    system
                    self
                    overlays
                    config
                    nixpkgs
                    pkgs
                    ;
                  defaultNixpkgs = nixpkgs-stable;
                };
              in
              {
                specialArgs = {
                  inherit self my;
                  inherit (self) inputs;
                };
                modules = [
                  (_: {
                    nixpkgs.pkgs = usePkgs;
                    nixpkgs.overlays = overlays;
                    networking.hostName = name;
                  })
                  home-manager.darwinModules.home-manager
                  self.darwinModules.default
                ]
                ++ lib.optionals (name == "localhost") [ (my.relativeToRoot "hosts/test/darwin.nix") ]
                ++ modules;
              }
            )
          );
      in
      {
        systems = [ "aarch64-darwin" ];

        imports = [ ./flake/common.nix ];

        flake.darwinConfigurations = {
          "test@aarch64-darwin" = mkdarwin {
            system = "aarch64-darwin";
            overlays = [ self.overlays.python ];
          };
          "lyeli@aarch64-darwin" = mkdarwin {
            system = "aarch64-darwin";
            overlays = [ self.overlays.python ];
            name = "home-box";
            modules = [ (self.my.relativeToRoot "hosts/homebox.nix") ];
          };
        };
      }
    );
}
