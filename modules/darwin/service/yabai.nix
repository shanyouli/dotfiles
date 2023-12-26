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
  buildSymlinks = pkgs.runCommandLocal "build-symlinks" {} ''
    mkdir -p $out/bin
    ln -s /usr/bin/{xcrun,codesign,xxd} $out/bin
  '';
  yabai = pkgs.yabai.overrideAttrs (prev: rec {
    # src = pkgs.fetchFromGitHub {
    #   owner = "FelixKratz";
    #   repo = "yabai";
    #   rev = "df5b037108c4a70dc5e854bb60ccbff9701da4f5";
    #   hash = "sha256-xMOwte/nuJdrwMWNLxfHikxA3btuyDyle6aLm5TD8ac=";
    # };
    version = "6.0.2";
    src = pkgs.fetchFromGitHub {
      owner = "koekeishiya";
      repo = "yabai";
      rev = "v${version}";
      hash = "sha256-VI7Gu5Y50Ed65ZUrseMXwmW/iovlRbAJGlPD7Ooajqw=";
    };
    nativeBuildInputs = (prev.nativeBuildInputes or []) ++ [buildSymlinks];
    dontBuild = false;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      codesign -s - -f ./bin/yabai
      cp -r ./bin $out
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
    my.hm.configFile."yabai" = {
      source = "${configDir}/yabai";
      recursive = true;
    };
    environment.systemPackages = [cfg.package];
    # https://github.com/LnL7/nix-darwin/blob/b8c286c82c6b47826a6c0377e7017052ad91353c/modules/services/yabai/default.nix#L79
    launchd.user.agents.yabai = {
      serviceConfig.ProgramArguments = ["${cfg.package}/bin/yabai" "--config" "${config.my.hm.configHome}/yabai/yabairc"];
      serviceConfig.KeepAlive = false;
      serviceConfig.RunAtLoad = true;
      serviceConfig.EnvironmentVariables = {
        PATH = "${cfg.package}/bin:${config.environment.systemPath}";
      };
    };
    # The scripting addition needs root access to load, which we want to do automatically when logging in.
    # Disable the password requirement for it so that a service can do so without user interaction.
    environment.etc."sudoers.d/yabai-load-sa".text =
      sudoNotPass config.user.name "${yabai}/bin/yabai";
  };
}
