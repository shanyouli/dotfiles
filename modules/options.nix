{ config, options, lib, home-manager, pkgs, ... }:

with lib;
with lib.my;
{
  options = with types; {
    user = mkOpt attrs {};

    home = {
      file       = mkOpt' attrs {} "Files to place directly in $HOME";
      configFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
      dataFile   = mkOpt' attrs {} "Files to place in $XDG_DATA_HOME";
      services   = mkOpt' attrs {} "User system service";
      sockets   = mkOpt' attrs {} "User system service";
      defaultApps = mkOpt' attrs {} "Default Applications";
      onReload = mkOpt' (attrsOf lines) {} "Run each update code.";
    };

    env = mkOption {
      type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
      apply = mapAttrs
        (n: v: if isList v
               then concatMapStringsSep ":" (x: toString x) v
               else (toString v));
      default = {};
      description = "TODO";
    };
    unsetenv = mkOption {
      type = with types; listOf str;
      default = [];
      description = "TODO";
    };
    rootRun = mkOption {
      type = with types; listOf str;
      default = [];
      description = "When ROOT is executed, you do not need a user password.";
    };
  };

  config = mkMerge [
    {
      user = {
        description = "The primary user account";
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        name = let name = builtins.getEnv "USER"; in
               if elem name [ "" "root" ]
               then "syl" else name;
        uid = 1000;
      };

      # Install user packages to /etc/profiles instead. Necessary for
      # nixos-rebuild build-vm to work.
      home-manager = {
        useUserPackages = true;

        # I only need a subset of home-manager's capabilities. That is, access to
        # its home.file, home.xdg.configFile and home.xdg.dataFile so I can deploy
        # files easily to my $HOME, but 'home-manager.users.hlissner.home.file.*'
        # is much too long and harder to maintain, so I've made aliases in:
        #
        #   home.file        ->  home-manager.users.hlissner.home.file
        #   home.configFile  ->  home-manager.users.hlissner.home.xdg.configFile
        #   home.dataFile    ->  home-manager.users.hlissner.home.xdg.dataFile
        users.${config.user.name} = {
          home = {
            file = mkAliasDefinitions options.home.file;
            # Necessary for home-manager to work with flakes, otherwise it will
            # look for a nixpkgs channel.
            stateVersion = config.system.stateVersion;
          };
          xdg = {
            configFile = mkAliasDefinitions options.home.configFile;
            dataFile   = mkAliasDefinitions options.home.dataFile;

            mime.enable = true;
            # NOTE: some application can change ~/.config/mimeapps.list
            mimeApps.enable = true;
            mimeApps.defaultApplications = mkAliasDefinitions options.home.defaultApps;
          };
          systemd.user.services = mkAliasDefinitions options.home.services;
          systemd.user.sockets = mkAliasDefinitions options.home.sockets;
        };
      };

      users.users.${config.user.name} = mkAliasDefinitions options.user;

      nix = let users = [ "root" config.user.name ]; in {
        trustedUsers = users;
        allowedUsers = users;
      };

      # must already begin with pre-existing PATH. Also, can't use binDir here,
      # because it contains a nix store path.
      env.PATH = [ "$XDG_CONFIG_HOME/dotfiles/bin" "$PATH" ];

      environment.extraInit = let
        exportLines = mapAttrsToList (n: v: "export ${n}=\"${v}\"") config.env;
        unsetVar    = map (str: "unset ${str}") config.unsetenv;
      in ''
        # Set Environment Variables
        ${concatStringsSep "\n" exportLines}

        # No longer use certain environment variables
        # unset ${toString config.unsetenv}
        ${concatStringsSep "\n" unsetVar}
      '';

      security.sudo.extraConfig = ''
        # No password is required to use the root permission execution.
        ${config.user.name} ALL=NOPASSWD: ${concatStringsSep "," config.rootRun}
      '';
    }
    # source ${config.system.build.setEnvironment}
    (mkIf (config.home.onReload != {}) (let
      switchReload = let
        path = [
          "${homeDir}/.nix-profile/bin"
          "/etc/profiles/per-user/${config.user.name}/bin"
          "/nix/var/nix/profiles/default/bin"
          "/run/current-system/sw/bin"
          "$PATH"
        ];
      in with pkgs; (writeScriptBin "switchReload" ''
        #!${stdenv.shell}
        echo "Import all custom system variables."
        export XDG_CACHE_HOME="${xdgCache}";
        export XDG_CONFIG_HOME="${xdgConfig}";
        export XDG_DATA_HOME="${xdgData}";
        export XDG_BIN_HOME="${xdgBin}";
        export PATH="${concatStringsSep ":" path }"
        ${concatStringsSep "\n"
          (mapAttrsToList (name: script: ''
            echo "[${name}]"
            ${script}
          '') config.home.onReload)}
        '');
    in {
      user.packages = [ switchReload ];
      system.userActivationScripts.switchReload = ''
        ${switchReload}/bin/switchReload
      '';
    }))
  ];
}
