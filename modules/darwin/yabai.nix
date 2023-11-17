{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.macos.yabai;
  buildSymlinks = pkgs.runCommandLocal "build-symlinks" {} ''
    mkdir -p $out/bin
    ln -s /usr/bin/{xcrun,codesign,xxd} $out/bin
  '';
  yabai = pkgs.yabai.overrideAttrs (prev: rec {
    src = pkgs.fetchFromGitHub {
      owner = "koekeishiya";
      repo = "yabai";
      rev = "v6.0.1";
      hash = "sha256-G7yjxhKk5Yz6qLHy8I8MMmZdVYUggGVvIW0j5kdkwlo=";
    };
    version = src.rev;
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
  options.my.modules.macos.yabai = {
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
    my.user.packages = [pkgs.yabai-zsh-completions];
    my.hm.configFile."yabai" = {
      source = "${configDir}/yabai";
      recursive = true;
    };
    environment.systemPackages = [cfg.package];
    # https://github.com/LnL7/nix-darwin/blob/b8c286c82c6b47826a6c0377e7017052ad91353c/modules/services/yabai/default.nix#L79
    launchd.user.agents.yabai = {
      script = ''
        exec ${cfg.package}/bin/yabai
      '';
      serviceConfig.KeepAlive = false;
      serviceConfig.RunAtLoad = true;
      serviceConfig.EnvironmentVariables = {
        PATH = "${cfg.package}/bin:${config.environment.systemPath}";
      };
    };
    # services.yabai = {
    #   # path = [ "${yabai}/bin"  config.environment.systemPath ];
    #   enable = true;
    #   package = yabai;
    #   # configFile = "${config.my.hm.configHome}/yabai/yabairc";
    # };
    # The scripting addition needs root access to load, which we want to do automatically when logging in.
    # Disable the password requirement for it so that a service can do so without user interaction.
    environment.etc."sudoers.d/yabai-load-sa".text =
      sudoNotPass config.my.username "${yabai}/bin/yabai";
  };
}
