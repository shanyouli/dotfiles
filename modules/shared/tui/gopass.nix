{
  config,
  options,
  pkgs,
  lib,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.gopass;
  package = pkgs.gopass;
  qtpass =
    if pkgs.stdenvNoCC.isLinux then
      pkgs.qtpass
    else
      pkgs.qtpass.overrideAttrs (_old: {
        postInstall = ''
          if [[ -d $out/bin/QtPass.app ]]; then
            mkdir -p $out/Applications
            mv $out/bin/*.app $out/Applications
            rm -rf $out/bin
          fi
          install -D qtpass.1 -t $out/share/man/man1
        '';
      });
in
{
  options.modules.gopass = with types; {
    enable = mkBoolOpt false;
    enGui = mkBoolOpt config.modules.gui.enable;
    browsers =
      let
        browsers = [
          "firefox"
          "chrome"
          "chromium"
          "brave"
          "librewolf"
          "vivaldi"
          "arc"
        ];
      in
      mkOption {
        type = types.listOf (types.enum browsers);
        default = [ ];
        example = [ "firefox" ];
        description = "Which browsers to install browserpass for";
      };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        package
        (mkIf cfg.enGui qtpass)
      ];
      env.PASSWORD_STORE_DIR = "${config.home.dataDir}/password-store";
      modules.shell.nushell.cmpFiles = [ "${my.dotfiles.config}/gopass/gopass-completions.nu" ];
    }
    (mkIf (cfg.browsers != [ ]) {
      home.file =
        let
          cfbrowser = config.modules.gui.browser.configDir;
          isFirefox =
            n:
            builtins.elem n [
              "firefox"
              "librewolf"
            ];
          nativeHostsName =
            n:
            if pkgs.stdenvNoCC.isLinux && (isFirefox n) then
              "native-messaging-hosts"
            else
              "NativeMessagingHosts";
          jsonFile = "com.github.browserpass.native.json";
          passJsonFn =
            n:
            (
              let
                browserName = if isFirefox n then "firefox" else "chromium";
              in
              "${pkgs.browserpass}/lib/browserpass/hosts/${browserName}/${jsonFile}"
            );
        in
        foldl' (a: b: a // b) { } (
          concatMap (
            x:
            if isFirefox x then
              [ { "${cfbrowser."${x}"}/${nativeHostsName x}/${jsonFile}".source = passJsonFn x; } ]
            else if x == "brave" then
              [ { "${cfbrowser.brave}/${nativeHostsName x}/${jsonFile}".source = passJsonFn x; } ]
            else if
              builtins.elem x [
                "chrome"
                "chromium"
                "vivaldi"
              ]
            then
              [
                {
                  "${cfbrowser."${x}"}/${nativeHostsName x}/${jsonFile}".source = passJsonFn x;
                  "${cfbrowser."${x}"}/policies/managed/${jsonFile}".source =
                    "${pkgs.browserpass}/lib/browserpass/policies/chromium/${jsonFile}";
                }
              ]
            else if x == "arc" then
              [
                {
                  "${my.homedir}/Library/Application Support/Arc/User Data/policies/managed/${jsonFile}".source =
                    "${pkgs.browserpass}/lib/browserpass/policies/chromium/${jsonFile}";
                  "${my.homedir}/Library/Application Support/Arc/User Data/NativeMessagingHosts/$(jsonFile)".source =
                    "${pkgs.browserpass}/lib/browserpass/hosts/chromiu/${jsonFile}";
                }
              ]
            else
              throw "unknown browser ${x}"
          ) cfg.browsers
        );
    })
  ]);
}
