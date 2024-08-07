{
  inputs,
  pkgs,
  ...
}: {
  # environment setup
  environment = {
    loginShell = pkgs.zsh;
    pathsToLink = ["/Applications"];
    # backupFileExtension = "backup";
    etc = {darwin.source = "${inputs.darwin}";};
    # Use a custom configuration.nix location.
    # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix

    # packages installed in system profile
    systemPackages = with pkgs; [findutils];
    # see@ https://github.com/LnL7/nix-darwin/issues/165
    etc = {
      "sudoers.d/00-not-commands".text = let
        commands = [
          "/sbin/shutdown"
          "/sbin/reboot"
        ];
        # ++ lib.optionals config.modules.service.clash.enable [ "/usr/sbin/networksetup" ];
        commandsString = builtins.concatStringsSep ", " commands;
      in ''
        %admin ALL=(ALL:ALL) NOPASSWD: ${commandsString}
      '';
    };
  };

  # nix.nixPath = ["darwin=/etc/${config.environment.etc.darwin.target}"];
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # auto manage nixbld users with nix darwin
  nix.configureBuildUsers = true;
  # users.nix.configureBuildUsers = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  documentation = {
    enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
  };
}
