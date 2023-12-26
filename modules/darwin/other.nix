{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules;
in {
  config = mkMerge [
    {
      user.packages = [
        # pkgs.qbittorrent-app
        pkgs.xbydriver-app
        # pkgs.chatgpt-app
        pkgs.chatgpt-next-web-app
        pkgs.localsend-app
        (lib.mkIf cfg.editor.nvim.enGui pkgs.neovide-app)
        # qutebrowser-app # 不再需要
        pkgs.upic-app
      ];
    }
    (mkIf cfg.firefox.enable {
      home.file."Library/Application Support/Firefox/Profiles/default/chrome" = {
        source = "${config.dotfiles.configDir}/firefox/chrome";
        recursive = true;
      };
    })
    (mkIf cfg.shell.gpg.enable {
      modules.service.env.GNUPGHOME = config.environment.variables.GNUPGHOME;
    })
    (mkIf cfg.shell.gopass.enable {
      modules.service.env.PASSWORD_STORE_DIR = config.env.PASSWORD_STORE_DIR;
    })
    (mkIf (cfg.dev.plugins != []) {
      macos.userScript.initAsdf = {
        desc = "Init asdf ...";
        text = cfg.dev.text;
      };
    })
  ];
}
