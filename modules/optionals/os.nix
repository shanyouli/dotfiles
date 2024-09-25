{
  config,
  options,
  lib,
  pkgs,
  inputs,
  home-manager,
  my,
  ...
}:
with lib;
with my; let
  name = my.user;
  inherit (my) homedir;
in {
  imports = [./common.nix];
  options = with types; {
    # user = mkOpt attrs {};
    user = mkOption {type = options.users.users.type.functor.wrapped;};
    home = {
      file = mkOpt' attrs {} "Files to place directly in $HOME";
      packages = mkOpt' (listOf package) [] "home-manager packages alias";
      profileBinDir = mkOpt' path "${homedir}/.nix-profile/bin" "home-manager profile-directory bin";
      activation = mkOpt' attrs {} "home-manager activation script";

      profileDirectory = mkOpt' path "" "";
    };
    modules.xdg.value = mkOpt types.attrs {};
  };
  config = mkMerge [
    {
      user = mkMerge [
        {
          inherit name;
          description = "The primary user account";
          home = homedir;
          uid = mkDefault 1000;
        }
        (mkIf pkgs.stdenvNoCC.isLinux {
          extraGroups = ["wheel"];
          group = "users";
          isNormalUser = true;
        })
      ];
      home = {
        programs.home-manager.enable = true;
        profileBinDir = "${config.home-manager.users."${config.user.name}".home.profileDirectory}/bin";

        profileDirectory = "${config.home-manager.users."${config.user.name}".home.profileDirectory}";
        useos = true;
        file = mapAttrs' (k: v: nameValuePair "${config.home.fakeDir}/${k}" v) config.home.fakeFile;
      };

      home-manager = {
        extraSpecialArgs = {inherit inputs;};
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.${config.user.name} = {
          home = {
            file = mkAliasDefinitions options.home.file;
            # Necessary for home-manager to work with flakes, otherwise it will
            # look for a nixpkgs channel.
            stateVersion =
              if pkgs.stdenv.isDarwin
              then "24.05"
              else config.system.stateVersion;
            username = config.user.name;

            activation = mkAliasDefinitions options.home.activation;
            packages = mkAliasDefinitions options.home.packages;
          };
          xdg = {
            enable = true;
            configFile = mkAliasDefinitions options.home.configFile;
            dataFile = mkAliasDefinitions options.home.dataFile;

            dataHome = mkAliasDefinitions options.home.dataDir;
            cacheHome = mkAliasDefinitions options.home.cacheDir;
            configHome = mkAliasDefinitions options.home.configDir;
            stateHome = mkAliasDefinitions options.home.stateDir;
          };
          programs = mkAliasDefinitions options.home.programs;
          services = mkAliasDefinitions options.home.services;
          home.enableNixpkgsReleaseCheck = false;
        };
      };

      users.users.${config.user.name} = mkAliasDefinitions options.user;

      environment.extraInit = mkOrder 10 (let
        inherit (pkgs.stdenvNoCC) isAarch64 isAarch32 isDarwin;
        darwinPath = optionalString isDarwin (let
          brewHome =
            if isAarch64 || isAarch32
            then "/opt/homebrew/bin"
            else "/usr/local/bin";
          prevPath =
            builtins.replaceStrings ["$USER" "$HOME"] [config.user.name homedir]
            (pkgs.lib.makeBinPath (builtins.filter (x: x != "/nix/var/nix/profiles/default") config.environment.profiles));
        in ''
          PATH=""
          eval $(/usr/libexec/path_helper -s)
          [ -d ${brewHome} ] && eval $(${brewHome}/brew shellenv)
          PATH=${prevPath}''${PATH:+:}$PATH
        '');
      in
        ''
          ${darwinPath}
        ''
        + concatStringsSep "\n" (mapAttrsToList (n: v: (
            if "${n}" == "PATH"
            then ''export ${n}="${v}:''${PATH:+:}$PATH"''
            else ''export ${n}="${v}"''
          ))
          config.env)
        + optionalString (config.nix.envVars != {}) ''
          unset all_proxy http_proxy https_proxy
        '');
      # 用来提示还有那些可以规范的文件。如何使用, 使用 my-xdg 脚本取代
      # environment.systemPackages = [pkgs.xdg-ninja];
      modules.xdg.value = {
        # These are the defaults, and xdg.enable does set them, but due to load
        # order, they're not set before environment.variables are set, which could
        # cause race conditions.
        XDG_CACHE_HOME = "${config.home.cacheDir}";
        XDG_CONFIG_HOME = "${config.home.configDir}";
        XDG_DATA_HOME = "${config.home.dataDir}";
        XDG_STATE_HOME = "${config.home.stateDir}";
        XDG_BIN_HOME = "${config.home.binDir}";
        XDG_FAKE_HOME = "${config.home.fakeDir}";
        XDG_RUNTIME_DIR =
          if pkgs.stdenvNoCC.isDarwin
          then "/tmp/user/${toString config.user.uid}"
          else "/run/user/${toString config.user.uid}";
      };
    }
    (mkIf config.modules.gui.enable {
      fonts.packages = config.modules.gui.fonts;
    })
    {
      environment = {
        systemPackages = with pkgs; [
          # standard toolset
          coreutils-full
          wget
          git
          jq

          # helpful shell stuff
          bat
          fzf
          (ripgrep.override {withPCRE2 = true;})
          #
          curl
          pkgs.unstable.cached-nix-shell # Better nix-shell
        ];
        etc = {
          home-manager.source = "${inputs.home-manager}";
          nixpkgs-unstable.source = "${inputs.nixpkgs}";
          nixpkgs.source =
            if pkgs.stdenvNoCC.isDarwin
            then "${inputs.darwin-stable}"
            else "${inputs.nixos-stable}";
        };
        # list of acceptable shells in /etc/shells
        shells = [pkgs.bash] ++ optionals config.modules.shell.zsh.enable [pkgs.zsh];
      };
      nix = let
        filterFn =
          if pkgs.stdenvNoCC.isLinux
          then (n: _: n != "self" && n != "darwin-stable")
          else (n: _: n != "self" && n != "nixos-stable");
        filteredInputs = filterAttrs filterFn inputs;
        nixPathInputs = mapAttrsToList (n: v:
          if (hasSuffix "stable" n)
          then "nixpkgs=${v}"
          else if n == "nixpkgs"
          then "nixpkgs-unstable=${v}"
          else "${n}=${v}")
        filteredInputs;
        registryInputs = mapAttrs (_: v: {flake = v;}) filteredInputs;
      in {
        registry = mkForce registryInputs // {dotfiles.flake = inputs.self;};
        nixPath =
          [
            "nixpkgs=/etc/nixpkgs"
            "nixpkgs-unstable=/etc/nixpkgs-unstable"
            "home-manager=/etc/home-manager"
          ]
          ++ (builtins.filter (x:
            !((hasPrefix "nixpkgs=" x)
              || (hasPrefix "nixpkgs-unstable=" x)
              || (hasPrefix "home-manager=" x)))
          nixPathInputs)
          ++ [
            "dotfiles=${my.dotfiles.dir}"
          ];
      };
    }
    (mkIf config.modules.shell.zsh.enable {
      programs.zsh = {
        enable = true;
        # 我将自动启用bashcompinit 和compinit配置
        enableCompletion = false;
        enableBashCompletion = false;
        promptInit = "";
      };
    })
    (mkIf (config.modules.shell.default == "zsh") {
      user.shell = pkgs.zsh;
    })
  ];
}
