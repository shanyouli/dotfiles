{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.zsh;
  toWgetConfig = opts:
    concatStringsSep "\n" (mapAttrsToList (p: v: "${p} = ${toString v}") opts);
in {
  options.my.modules = {
    zsh = with types; {
      enZinit = mkBoolOpt false;
      zoxide = mkBoolOpt true;
      navi = mkBoolOpt true;
      vivid = mkBoolOpt true;
      aliases = mkOpt (attrsOf (either str path)) {};
      env = mkOption {
        type = attrsOf (oneOf [str path (listOf (either str path))]);
        apply = mapAttrs (n: v:
          if isList v
          then concatMapStringsSep ":" toString v
          else (toString v));
        default = {};
        description = "TODO";
      };
      rcInit = mkOpt' lines "" ''
        Zsh lines to be written to $XDG_CONFIG_HOME/zsh/extra.zshrc and sourced by
        $XDG_CONFIG_HOME/zsh/.zshrc
      '';
      envInit = mkOpt' lines "" ''
        Zsh lines to be written to $XDG_CONFIG_HOME/zsh/extra.zshenv and sourced
        by $XDG_CONFIG_HOME/zsh/.zshenv
      '';
      prevInit = mkOpt' lines "" "zshrc pre";
      rcFiles = mkOpt (listOf (either str path)) [];
      envFiles = mkOpt (listOf (either str path)) [];
    };
    wget = {
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
  };

  # 一些现代命令行工具的推荐:https://github.com/ibraheemdev/modern-unix
  config = mkMerge [
    {
      # lib.mkIf cfg.enable (lib.mkMerge [{ users.defaultUserShell = pkgs.zsh; }]);
      # only nixos
      # users.defaultUserShell = pkgs.zsh;
      my.user.shell = pkgs.zsh;
      programs.zsh = {
        enable = true;
        # 我将自动启用bashcompinit 和compinit配置
        enableCompletion = false;
        enableBashCompletion = false;
        promptInit = "";
      };
      my.user.packages = with pkgs; [
        zsh
        bottom
        fd
        eza
        nix-index
        bat
        any-nix-shell
        wget
        nurl # better nix-prefetch-xxx
        duf
        httrack # 网页抓取
        # atuin # history配置
      ];
      env = {
        PATH = ["${config.my.hm.binHome}"];
        ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
        ZSH_CACHE = "${config.my.hm.cacheHome}/zsh";
      };
      my.modules.zsh = {
        prevInit = ''
          # starship和p10有自己的提示方法；--info-right
          _cache ${pkgs.any-nix-shell}/bin/any-nix-shell zsh
          source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
          # _cache "${pkgs.atuin}"/bin/atuin init zsh
        '';
        aliases = {
          htop = "btm --basic";
          wget = "${pkgs.wget}/bin/wget --hsts-file ${config.my.hm.cacheHome}/wget-hsts";
        };
      };

      # WGETRC
      my.modules.wget.settings = {
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
        hsts-file = "${config.my.hm.cacheHome}/wget-hsts";
      };

      my.hm = {
        configFile = {
          "bat/themes" = {
            source = "${configDir}/bat/themes";
            recursive = true;
          };
          "zsh" = {
            source = "${configDir}/zsh";
            recursive = true;
          };
          "zsh/prev.zshrc".text = ''
            ${cfg.prevInit}
          '';
          "zsh/extra.zshrc".text = let
            p10 =
              if config.my.modules.starship.enable
              then "_cache starship init zsh --print-full-init"
              else ''
                zinit ice depth=1
                zinit light romkatv/powerlevel10k
              '';
            aliasLines =
              mapAttrsToList (n: v: ''alias ${n}="${v}"'') cfg.aliases;
            sourceFn =
              if cfg.enZinit
              then "zinit snippet"
              else "source";
          in ''
            # This file was autogenerated, do not edit it!
            ${p10}
            ${concatStringsSep "\n" aliasLines}
            ${concatMapStrings (path: ''
                ${sourceFn} '${path}'
              '')
              cfg.rcFiles}
            ${cfg.rcInit}
          '';
          "zsh/extra.zshenv".text = let
            envLines =
              mapAttrsToList (n: v: (
                if "${n}" == "PATH"
                then ''export ${n}="${v}:$PATH"''
                else ''export ${n}="${v}"''
              ))
              cfg.env;
            dotfiles =
              if pkgs.stdenvNoCC.isDarwin
              then "${config.my.hm.dir}/.nixpkgs"
              else "/etc/nixos";
          in ''
            if [ -n "$__MY_ZSHENV_SOURCED" ]; then return; fi
            export __MY_ZSHENV_SOURCED=1
            # This file is autogenerated, do not edit it!
            export DOTFILES=${dotfiles}
            ${concatStringsSep "\n" envLines}
            ${concatMapStrings (path: ''
                source '${path}'
              '')
              cfg.envFiles}
            ${cfg.envInit}
          '';
        };
      };
    }
    (mkIf cfg.zoxide {
      my.user.packages = [pkgs.zoxide];
      my.modules.zsh.rcInit = ''
        _cache zoxide init zsh
      '';
    })
    (mkIf cfg.navi {
      my.user.packages = [pkgs.navi];
    })
    # 一个更好的LS_COLORS 工具: https://github.com/sharkdp/vivid
    (mkIf cfg.vivid {
      my.user.packages = [pkgs.vivid];
    })
    (mkIf (config.my.modules.wget.settings != {})
      (let
        wgetrc = "${config.my.hm.configHome}/wgetrc";
      in {
        environment.variables.WGETRC = wgetrc;
        my.hm.configFile."wgetrc".text = toWgetConfig config.my.modules.wget.settings;
      }))
    (mkIf cfg.enZinit {
      my.user.packages = [pkgs.zinit];
      my.modules.zsh.env.ZINIT_HOME = "${pkgs.zinit}/share/zinit";
    })
  ];
}
