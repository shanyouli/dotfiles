{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.my; {
  environment = {
    variables.ODOTFILES = config.dotfiles.dir;
    systemPackages = with pkgs; [
      # standard toolset
      coreutils-full
      # curl
      wget
      git
      jq

      # helpful shell stuff
      bat
      fzf
      (pkgs.ripgrep.override {withPCRE2 = true;})
      #
      curl
    ];
    etc = {
      home-manager.source = "${inputs.home-manager}";
      nixpkgs.source = "${pkgs.path}";
      stable.source =
        if pkgs.stdenvNoCC.isDarwin
        then "${inputs.darwin-stable}"
        else "${inputs.nixos-stable}";
    };
    # list of acceptable shells in /etc/shells
    shells = with pkgs; [bash zsh];
  };
  # nixpkgs.config = {
  #   allowUnsupportedSystem = false;
  #   allowUnfree = true;
  #   allowBroken = false;
  # };
  documentation.man.enable = true;
  nix = {
    # envVars = {
    #   https_proxy = "http://127.0.0.1:7890";
    #   http_proxy = "http://127.0.0.1:7890";
    #   all_proxy = "http://127.0.0.1:7890";

    # };
    package = pkgs.nix;
    nixPath = builtins.map (source: "${source}=/etc/${config.environment.etc.${source}.target}") [
      "home-manager"
      "nixpkgs"
      "stable"
    ];
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = {
      max-jobs = 4;
      substituters = pkgs.lib.mkBefore [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        # "https://mirrors.cernet.edu.cn/nix-channels/store"
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
}
