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
    variables.DOTFILES = config.dotfiles.dir;

    variables.NIXPKGS_ALLOW_UNFREE = "1";

    systemPackages = with pkgs; [
      # standard toolset
      coreutils-full
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
      nixpkgs.source = "${inputs.nixpkgs}";
      stable.source =
        if pkgs.stdenvNoCC.isDarwin
        then "${inputs.darwin-stable}"
        else "${inputs.nixos-stable}";
    };
    # list of acceptable shells in /etc/shells
    shells = with pkgs; [bash zsh];
  };
  documentation.man.enable = mkDefault true;
  nix = let
    filterFn =
      if pkgs.stdenvNoCC.isLinux
      then (n: _: n != "self" && n != "darwin-stable")
      else (n: _: n != "self" && n != "nixos-stable");
    filteredInputs = filterAttrs filterFn inputs;
    nixPathInputs = mapAttrsToList (n: v:
      if (hasSuffix "stable" n)
      then "stable=${v}"
      else "${n}=${v}")
    filteredInputs;
    registryInputs = mapAttrs (_: v: {flake = v;}) filteredInputs;
  in {
    # envVars = {
    #   https_proxy = "http://127.0.0.1:7890";
    #   http_proxy = "http://127.0.0.1:7890";
    #   all_proxy = "http://127.0.0.1:7890";

    # };
    registry = registryInputs // {dotfiles.flake = inputs.self;};
    nixPath =
      nixPathInputs
      ++ [
        # "nixpkgs-overlays=${config.dotfiles.dir}/overlays"
        "dotfiles=${config.dotfiles.dir}"
      ];
    package = pkgs.nix;
    gc = {
      automatic = mkDefault true;
      options = mkDefault "--delete-older-than 7d";
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
      auto-optimise-store = mkDefault true;
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "shanyouli.cachix.org-1:19ndCE7zQfn5vIVLbBZk6XG0D7Ago7oRNNgIRV/Oabw="
      ];
    };
  };
}
