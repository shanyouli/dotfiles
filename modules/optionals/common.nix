{
  pkgs,
  lib,
  config,
  options,
  myvars,
  ...
}:
with lib;
with lib.my; let
  inherit (myvars) homedir;
in {
  options = with types; {
    home.programs = mkOpt' attrs {} "home-manager programs";
    env = mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (_n: v:
        if isList v
        then concatMapStringsSep ":" toString v
        else (toString v));
      default = {};
      description = "Configuring System Environment Variables";
    };
    home.actionscript = mkOpt' lines "" "激活时，运行代码";

    home.configFile = mkOpt' attrs {} "Files to place directly in $XDG_CONFIG_HOME";
    home.dataFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";

    home.dataDir = mkOpt' path "${homedir}/.local/share" "xdg_data_home";
    home.stateDir = mkOpt' path "${homedir}/.local/state" "xdg_state_home";
    home.binDir = mkOpt' path "${homedir}/.local/bin" "xdg_bin_home";
    home.configDir = mkOpt' path "${homedir}/.config" "xdg_config_home";
    home.cacheDir = mkOpt' path "${homedir}/.cache" "xdg_cache_home";

    home.services = mkOpt' attrs {} "home-manager user script";
  };
  config = {
    # documentation.man.enable = mkDefault true;
    nix = {
      # envVars = {
      #   https_proxy = "http://127.0.0.1:7890";
      #   http_proxy = "http://127.0.0.1:7890";
      #   all_proxy = "http://127.0.0.1:7890";

      # };
      package = mkDefault pkgs.nix;
      gc = {
        automatic = mkDefault true;
        options = mkDefault "--delete-older-than 7d";
      };
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
      settings = let
        users = ["root" myvars.user "@admin" "@wheel"];
      in {
        trusted-users = users;
        allowed-users = users;
        max-jobs = 4;
        substituters = pkgs.lib.mkBefore [
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          # "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://shanyouli.cachix.org"
        ];
        # Using hard links
        auto-optimise-store = mkDefault true;
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "shanyouli.cachix.org-1:19ndCE7zQfn5vIVLbBZk6XG0D7Ago7oRNNgIRV/Oabw="
        ];
      };
    };
  };
}
