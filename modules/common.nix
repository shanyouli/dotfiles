{
  inputs,
  pkgs,
  ...
}: {
  imports = [./primary.nix ./nixpkgs.nix];

  # bootstrap home manager using system config
  hm = import ./home-manager;

  # environment setup
  environment = {
    systemPackages = with pkgs; [
      # standard toolset
      coreutils-full
      #curl
      # wget
      git
      jq

      # helpful shell stuff
      bat
      fzf
      (pkgs.ripgrep.override {withPCRE2 = true;})

      # languages
      python3
      ruby
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

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      fantasque-sans-mono
      cascadia-code
      codicons
      lxgw-wenkai
      unifont
      (nerdfonts.override {fonts = ["FantasqueSansMono"];})
      # maple-mono
      # maple-sc
      julia-mono
      monaspace
    ];
  };
}
