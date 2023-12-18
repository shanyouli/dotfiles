{
  description = "nix system configurations";

  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "darwin-stable";
    };
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    # @see https://github.com/nix-community/emacs-overlay/issues/275
    # emacs-src.url = "github:emacs-mirror/emacs/emacs-29";
    # emacs-src.flake = false;
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # shell stuff
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    darwin,
    home-manager,
    flake-utils,
    devenv,
    darwin-stable,
    nixos-stable,
    ...
  }: let
    inherit (flake-utils.lib) eachSystemMap;
    inherit (lib) attrValues;
    inherit (lib.my) defaultSystems mkPkgs mkPkg;
    allPkgs = mkPkgs {
      nixpkgs = [nixos-stable darwin-stable];
      cfg = {allowUnfree = true;};
      overlays = self.overlays // {};
    };

    sharedHostsConfig = {
      config,
      pkgs,
      ...
    }: {
      nix = {
        package = pkgs.nix;
        gc = {
          automatic = true;
          options = "--delete-older-than 7d";
        };
        # readOnlyStore = true; # nixos only
        extraOptions = ''
          keep-outputs = true
          keep-derivations = true
          experimental-features = nix-command flakes
        '';
        settings = {
          max-jobs = 4;
          substituters = pkgs.lib.mkBefore [
            "https://mirrors.cernet.edu.cn/nix-channels/store"
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://mirror.sjtu.edu.cn/nix-channels/store"
            # "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://shanyouli.cachix.org"
          ];
          # Using hard links
          auto-optimise-store = true;
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "shanyouli.cachix.org-1:19ndCE7zQfn5vIVLbBZk6XG0D7Ago7oRNNgIRV/Oabw="
          ];
        };
      };
      nixpkgs.config = {
        allowUnsupportedSystem = true;
        allowUnfree = true;
        allowBroken = false;
      };
      time.timeZone = config.my.timezone;

      documentation.man = {
        enable = true;
        # Currently doesn't work in nix-darwin
        # https://discourse.nixos.org/t/man-k-apropos-return-nothing-appropriate/15464
        # generateCaches = true;
      };
    };
    # with overlays and any extraModules applied
    lib = nixpkgs.lib.extend (self: super: {
      my = import ./lib {
        inherit inputs;
        lib = self;
      };
    });
  in {
    lib = lib.my;
    checks =
      {}
      // (lib.my.mkChecks {
        inherit self;
        arch = "aarch64";
        os = "darwin";
      })
      // (lib.my.mkChecks {
        inherit self;
        arch = "x86_64";
        os = "linux";
        username = "shanyouli";
      });

    darwinConfigurations = {
      Lye-MAC = lib.my.mkDarwinConfig {
        name = "home-box";
        system = "aarch64-darwin";
        darwin = inputs.darwin;
        allPkgs = allPkgs;
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays =
              (builtins.attrValues self.overlays) ++ [inputs.nixpkgs-firefox-darwin.overlay];
          }
          home-manager.darwinModules.home-manager
          sharedHostsConfig
        ];
        extraModules = [./hosts/homebox.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
      "lyeli@aarch64-darwin" = lib.my.mkDarwinConfig {
        name = "home-box";
        system = "aarch64-darwin";
        darwin = inputs.darwin;
        allPkgs = allPkgs;
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays =
              (builtins.attrValues self.overlays) ++ [inputs.nixpkgs-firefox-darwin.overlay];
          }
          home-manager.darwinModules.home-manager
          sharedHostsConfig
        ];
        extraModules = [./hosts/homebox.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
      "lyeli@x86_64-darwin" = lib.my.mkDarwinConfig {
        name = "home-box";
        darwin = inputs.darwin;
        allPkgs = allPkgs;
        system = "x86_64-darwin";
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays =
              (builtins.attrValues self.overlays) ++ [inputs.nixpkgs-firefox-darwin.overlay];
          }
          home-manager.darwinModules.home-manager
          sharedHostsConfig
        ];
        extraModules = [./host/test.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
    };

    nixosConfigurations = {
      "shanyouli@x86_64-linux" = lib.my.mkNixosConfig {
        name = "nixos-work";
        nixos = inputs.nixos-stable;
        allPkgs = allPkgs;
        extraModules = [
          ./modules/hardware/phil.nix
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t460s
          ./pofiles/personal.nix
        ];
        baseModules = [
          home-manager.nixosModules.home-manager
          sharedHostsConfig
        ];
        specialArgs = {inherit inputs nixpkgs lib self;};
      };
    };

    devShells = eachSystemMap defaultSystems (system: let
      pkgs = mkPkg {
        inherit system;
        nixpkgs = inputs.nixpkgs;
        overlays = self.overlays;
      };
    in {
      default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [(import ./devenv.nix)];
      };
    });
    packages = lib.my.withDefaultSystems (system: let
      pkgs = allPkgs."${system}";
    in rec {
      sysdo = pkgs.sysdo;
      # devenv = inputs.devenv.defaultPackage.${system};
    });

    apps = lib.my.withDefaultSystems (system: rec {
      sysdo = {
        type = "app";
        program = "${self.packages.${system}.sysdo}/bin/sysdo";
      };
      # 加载配置, nix run .#repl
      # @see https://github.com/NixOS/nix/issues/3803#issuecomment-748612294
      repl = flake-utils.lib.mkApp {
        drv = let
          pkgs = allPkgs."${system}";
        in
          pkgs.writeScriptBin "repl" ''
            confnix=$(mktemp)
            echo "import <nixpkgs> {} // (builtins.getFlake (toString $(git rev-parse --show-toplevel)))" >$confnix
            trap "rm $confnix" EXIT
            nix repl --file $confnix
          '';
      };
      default = sysdo;
    });

    overlays = {
      channels = final: prev: {
        # expose other channels via overlays
        unstable = mkPkg {
          system = prev.system;
          cfg = {allowUnfree = true;};
          nixpkgs = inputs.nixpkgs;
        };
        # small = import inputs.small {system = prev.system;};
        devenv = inputs.devenv.defaultPackage.${prev.system};
      };
      python = final: prev: let
        packageOverrides = pfinal: pprev:
          prev.callPackage ./packages/python-modes.nix {python3Packages = pprev;}
          // {
            # pyopenssl = pprev.pyopenssl.overrideAttrs
            #   (old: { meta = old.meta // { broken = false; }; });
            # poetry =
            #   pprev.poetry.overridePythonAttrs (old: { doCheck = false; });
            musicdl = pprev.toPythonModule (prev.callPackage ./packages/musicdl.nix {python3Packages = pprev;});
            websocket-bridge-python =
              pprev.toPythonModule (prev.callPackage ./packages/websocket-bridge-python.nix {python3Packages = pprev;});
          };
      in {
        python3 = prev.python3.override {inherit packageOverrides;};
        pypy3 = prev.pypy3.override {inherit packageOverrides;};
        python39 = prev.python39.override {inherit packageOverrides;};
        python310 =
          prev.python310.override {inherit packageOverrides;};
      };
      my = final: prev: {
        maple-mono = prev.callPackage ./packages/maple-mono.nix {};
        maple-sc = prev.callPackage ./packages/maple-sc.nix {};
        codicons = prev.callPackage ./packages/codicons.nix {};
        xray-asset = prev.callPackage ./packages/xray-asset.nix {};
        my-nix-scripts = prev.callPackage ./packages/nix-script.nix {};
        deeplx = prev.callPackage ./packages/deeplx.nix {};
        musicn = prev.callPackage ./packages/musicn {};
        go-musicfox = prev.callPackage ./packages/go-musicfox.nix {};
        lazyvim-star = prev.callPackage ./packages/lazyvim-star.nix {};
        sysdo = prev.callPackage ./packages/sysdo {};
        yutto = prev.callPackage ./packages/yutto.nix {};
        mihomo = prev.callPackage ./packages/mihomo.nix {};
      };
      macos = final: prev: {
        yabai-zsh-completions =
          prev.callPackage ./packages/yabai-zsh-completions.nix {};
        alist = prev.callPackage ./packages/alist.nix {};
        mosdns = prev.callPackage ./packages/mosdns.nix {};
        seam = prev.callPackage ./packages/seam.nix {};
        bbdown = prev.callPackage ./packages/bbdown.nix {};
        mybid = prev.callPackage ./packages/mybid {};
      };
      darwinApp =
        import ./packages/darwinApp {inherit (inputs.nixpkgs) lib;};
      nur = inputs.nur.overlay;
    };
  };
}
