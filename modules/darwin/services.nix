{
  config,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
in {
  launchd.user.agents = mkMerge [
    # (mkIf config.modules.gpg.enable {
    #   gpg = {
    #     serviceConfig.ProgramArguments = [
    #       "${pkgs.gnupg}/bin/gpg-connect-agent"
    #     ];
    #     serviceConfig.KeepAlive = true;
    #     serviceConfig.RunAtLoad = true;
    #     serviceConfig.EnvironmentVariables = {
    #       PATH = "${pkgs.gnupg}/bin:${config.environment.systemPath}";
    #       GNUPGHOME = "${config.my.hm.configHome}/gnupg";
    #     };
    #   };
    # })
    {
      env = {
        script = ''
          # Use launchctl set the environment variable
          # /bin/launchctl setenv env value
          ${optionalString config.modules.gpg.enable
            "/bin/launchctl setenv GNUPGHOME ${config.environment.variables.GNUPGHOME}"}
          ${optionalString config.modules.gopass.enable
            "/bin/launchctl setenv PASSWORD_STORE_DIR ${config.env.PASSWORD_STORE_DIR}"}
        '';
        path = [config.environment.systemPath];
        serviceConfig.RunAtLoad = true;
      };
    }
  ];
  macos.userScript.initRustup = {
    enable = cfm.rust.enable && cfm.rust.rustup.enable;
    desc = "初始化rust";
    text = cfm.rust.rustup.script;
  };
  macos.userScript.initCargo = {
    enable = cfm.rust.enable;
    desc = "初始化cargo";
    text = cfm.rust.cargoScript;
  };
  macos.userScript.initNvim = {
    enable = cfm.nvim.enable;
    desc = "Init nvim";
    text = cfm.nvim.script;
  };
}
