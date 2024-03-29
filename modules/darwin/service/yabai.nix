{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.yabai;
  srcs = (import "${config.dotfiles.srcDir}/generated.nix") {
    inherit (pkgs) fetchurl fetchFromGitHub fetchgit dockerTools;
  };
  buildSymlinks = pkgs.runCommandLocal "build-symlinks" {} ''
    mkdir -p $out/bin
    ln -s /usr/bin/{xcrun,codesign,xxd} $out/bin
  '';
  yabai = pkgs.yabai.overrideAttrs (prev: rec {
    inherit (srcs.yabai) version src;
    nativeBuildInputs = (prev.nativeBuildInputes or []) ++ [buildSymlinks pkgs.installShellFiles];
    dontBuild = false;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      codesign -s - -f ./bin/yabai
      cp -r ./bin $out
      installManPage ./doc/yabai.1
      runHook postInstall
    '';
  });
in {
  options.modules.service.yabai = {
    enable = mkBoolOpt false;
    package = mkOption {
      type = types.package;
      default = yabai;
      defaultText = literalExample "pkgs.yabai";
      example = literalExample "pkgs.yabai";
      description = "The Yabai Package to use.";
    };
  };

  config = mkIf cfg.enable {
    user.packages = [pkgs.yabai-zsh-completions];
    home.configFile."yabai" = {
      source = "${config.dotfiles.configDir}/yabai";
      recursive = true;
    };
    environment.systemPackages = [cfg.package];
    # https://github.com/LnL7/nix-darwin/blob/b8c286c82c6b47826a6c0377e7017052ad91353c/modules/services/yabai/default.nix#L79
    launchd.user.agents.yabai = {
      serviceConfig.ProgramArguments = ["${cfg.package}/bin/yabai" "--config" "${config.home.configDir}/yabai/yabairc"];
      serviceConfig.KeepAlive = false;
      serviceConfig.RunAtLoad = true;
      serviceConfig.EnvironmentVariables.PATH = "${cfg.package}/bin:${config.modules.service.path}";
    };
    # The scripting addition needs root access to load, which we want to do automatically when logging in.
    # Disable the password requirement for it so that a service can do so without user interaction.
    environment.etc."sudoers.d/yabai-load-sa".text =
      sudoNotPass config.user.name "${yabai}/bin/yabai";
  };
}
