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
  nix = {
    # envVars = {
    #   https_proxy = "http://127.0.0.1:7890";
    #   http_proxy = "http://127.0.0.1:7890";
    #   all_proxy = "http://127.0.0.1:7890";

    # };
    nixPath = builtins.map (source: "${source}=/etc/${config.environment.etc.${source}.target}") [
      "home-manager"
      "nixpkgs"
      "stable"
    ];
  };
}
