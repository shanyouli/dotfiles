{
  config,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
  pyEnv =
    pkgs.python3.withPackages (ps: with ps; [typer colorama shellingham]);
  sysDoNixos = "[[ -d /etc/nixos ]] && cd /etc/nixos && ${pyEnv}/bin/python bin/do.py $@";
  sysDoDarwin = "[[ -d ${homeDir}/.nixpkgs ]] && cd ${homeDir}/.nixpkgs && ${pyEnv}/bin/python bin/do.py $@";
  sysdo = pkgs.writeShellScriptBin "sysdo" ''
    (${sysDoNixos}) || (${sysDoDarwin})
  '';
in {
  imports = [
    # ./cli
    ./dotfiles
    # ./git.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.home-manager = {
    enable = true;
    path = "${config.home.homeDirectory}/.nixpkgs/modules/home-manager";
  };

  home = {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    # stateVersion = "22.11";
    sessionVariables = {
      GPG_TTY = "/dev/ttys000";
      EDITOR = "nvim";
      VISUAL = "nvim";
      CLICOLOR = 1;
      LSCOLORS = "ExFxBxDxCxegedabagacad";
      KAGGLE_CONFIG_DIR = "${config.xdg.configHome}/kaggle";
      JAVA_HOME = "${pkgs.openjdk11.home}";
    };
    sessionPath = [
      "${config.home.homeDirectory}/.rd/bin"
    ];

    # define package definitions for current user environment
    packages = with pkgs; let
      my-wget = let
        flags = ''--hsts-file="${config.home.homeDirectory}/.cache/wget-hsts" -c'';
      in
        symlinkJoin {
          name = "my-wget-${wget.version}";
          paths = [wget];
          buildInputs = [makeWrapper];
          postBuild = ''wrapProgram $out/bin/wget --add-flags "${flags}"'';
        };
    in [
      my-wget
      age
      cachix
      comma
      curl
      fd
      ffmpeg
      gawk
      ghc
      git
      gnugrep
      gnupg
      gnused
      htop
      # httpie
      jq
      luajit
      mmv
      neofetch
      nix
      openjdk11
      openssh
      pandoc
      parallel
      # pkgs.coreutils-full
      pkgs.coreutils-prefixed
      pre-commit
      ranger
      (pkgs.ruby.withPackages (ps: with ps; [rufo solargraph]))
      (pkgs.ripgrep.override {withPCRE2 = true;})
      rsync
      shellcheck
      stylua
      sysdo
      tealdeer
      terraform
      treefmt
      vagrant
      hugo
      imagemagick
      gifsicle
    ];
  };
}
