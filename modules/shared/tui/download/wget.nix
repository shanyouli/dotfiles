{
  lib,
  config,
  options,
  pkgs,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.download;
  cfg = cfp.wget;
  toWgetConfig = opts:
    concatStringsSep "\n" (mapAttrsToList (p: v: "${p} = ${toString v}") opts);
  cfbin = "${cfg.package}/bin/wget";
in {
  options.modules.download.wget = {
    enable = mkBoolOpt cfp.enable;
    package = mkOpt' types.package pkgs.wget "Whether to package";
    settings = with types;
      mkOption {
        type = attrs;
        default = {};
        example = liberalExpression ''
          {
            timeout = 60;
          }
        '';
      };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [cfg.package];
      modules.download.wget.settings = {
        # Use the server-provided last modification date, if available
        timestamping = "on";
        # Do not go up in the directory structure when downloading recursively
        no_parent = "on";
        # Wait 60 seconds before timing out. This applies to all timeouts: DNS, connect and read. (The default read timeout is 15 minutes!)
        timeout = 60;
        # Retry a few times when a download fails, but don’t overdo it. (The default is 20!)
        tries = 3;
        # Retry even when the connection was refused
        retry_connrefused = "on";
        # Use the last component of a redirection URL for the local file name
        trust_server_names = "on";
        # Add a `.html` extension to `text/html` or `application/xhtml+xml` files that lack one, or a `.css` extension to `text/css` files that lack one

        adjust_extension = "on";
        # Use UTF-8 as the default system encoding
        #local_encoding = "UTF-8";
        # Ignore `robots.txt` and `<meta name=robots content=nofollow>`
        robots = "off";
        # Print the HTTP and FTP server responses
        server_response = "on";
        # Disguise as IE 9 on Windows 7
        # user_agent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)";
        # force continuation of preexistent partially retrieved files.
        continue = "on";
        # Try to avoid `~/.wget-hsts`. Wget only supports absolute path, so be it.
        # (https://www.gnu.org/software/wget/manual/html_node/HTTPS-_0028SSL_002fTLS_0029-Options.html)
        hsts-file = "${config.home.cacheDir}/wget-hsts";
      };
      modules.shell.aliases.wget = "${cfbin} --hsts-file ${config.home.cacheDir}/wget-hsts";
    }
    (mkIf (cfg.settings != {}) {
      env.WGETRC = ''''${XDG_CONFIG_HOME:-~/.config}/wget/wgetrc'';
      home.configFile."wget/wgetrc".text = toWgetConfig cfg.settings;
    })
  ]);
}
