{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.macos;
  filterEnabledTexts = dict: let
    attrList = lib.attrValues dict;
    filterLambda = x:
      if builtins.hasAttr "enable" x
      then x.enable
      else true;
    sortLambda = x: y: let
      levelx =
        if builtins.hasAttr "level" x
        then x.level
        else 50;
      levely =
        if builtins.hasAttr "level" y
        then y.level
        else 50;
    in
      levelx < levely;
    sortFn = la: pkgs.lib.sort sortLambda la;
  in
    lib.concatMapStrings (enableText: ''
      ${lib.optionalString (hasAttr "desc" enableText)
        "echo-info '${enableText.desc}' "}
      ${enableText.text}
    '') (sortFn (lib.filter filterLambda attrList));
  prevtext = ''
    #!${pkgs.stdenv.shell}

    # HACK: Unable to use nix installed git in scripts
    export PATH=/usr/bin:$PATH

    # 一些echo 函数
    if command -v tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi

    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        BOLD="$(tput bold)"
        NORMAL="$(tput sgr0)"
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        NORMAL=""
    fi
    echo-debug() { printf "''${BLUE}''${BOLD}$*''${NORMAL}\n"; }
    echo-info() { printf "''${GREEN}''${BOLD}$*''${NORMAL}\n"; }
    echo-warn() { printf "''${YELLOW}''${BOLD}$*''${NORMAL}\n"; }
    echo-error() { printf "''${RED}''${BOLD}$*''${NORMAL}\n"; }
  '';
  userScripts = pkgs.writeScript "postUserScript" ''
    ${prevtext}
    ${filterEnabledTexts cfg.userScript}
  '';
  systemScripts = pkgs.writeScript "postSystemScript" ''
    ${prevtext}
    ${filterEnabledTexts cfg.systemScript}
  '';
in {
  options.macos = with types; {
    userScript = mkOpt attrs {};
    systemScript = mkOpt attrs {};
  };
  config = mkMerge [
    {
      user.packages = [
        # pkgs.qbittorrent-app
        pkgs.xbydriver-app
        # pkgs.chatgpt-app
        pkgs.chatgpt-next-web-app
        pkgs.localsend-app
        (lib.mkIf config.modules.editor.nvim.enGui pkgs.neovide-app)
        # qutebrowser-app # 不再需要
        pkgs.upic-app
      ];

      modules.xdg.enable = true;
      environment.variables = config.modules.xdg.value;

      modules.opt.enGui = true;
      system.activationScripts.postActivation.text = ''
        echo "System script executed after system activation"
        ${systemScripts}
        echo "User script excuted after system activation"
        sudo -u ${config.user.name} --set-home ${userScripts}
      '';
      macos.systemScript.removeNixApps.text = ''
        echo-info "Remove /Applications/Nix\ Apps ..."
        if [[ -e '/Applications/Nix Apps' ]]; then
          $DRY_RUN_CMD rm -rf '/Applications/Nix Apps'
        fi
      '';
      macos.systemScript.zshell.text = ''
        echo-info "setting Default Shell"
        chsh -s /run/current-system/sw/bin/zsh ${config.user.name}
      '';
      macos.userScript.clear_zsh.text = ''
        echo-info "Clear zsh ..."
        if [[ -d ${config.env.ZSH_CACHE}/cache ]]; then
          $DRY_RUN_CMD rm -rf ${config.env.ZSH_CACHE}/cache
        fi
        command -v bat >/dev/null && bat cache --build >/dev/null

        # 禁止在 USB 卷创建元数据文件, .DS_Store
        defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
        # 禁止在网络卷创建元数据文件
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
      '';
      macos.userScript.initRust = {
        enable = config.modules.dev.rust.enable;
        desc = "init rust";
        text = config.modules.dev.rust.initScript;
      };
      macos.userScript.initNvim = {
        enable = config.modules.editor.nvim.enable;
        desc = "Init nvim";
        text = config.modules.editor.nvim.script;
      };
    }
    (mkIf config.modules.firefox.enable (
      let
        base = "Library/Application Support/Firefox/Profiles/default/chrome";
        configDir = config.dotfiles.configDir;
      in {
        home.file."${base}/utils" = {
          source = "${pkgs.firefox-utils}/share/utils";
          recursive = true;
        };
        home.file."${base}/css" = {
          source = "${configDir}/firefox/css";
          recursive = true;
        };
      }
    ))
    (mkIf config.modules.shell.gpg.enable {
      modules.service.env.GNUPGHOME = config.environment.variables.GNUPGHOME;
    })
    (mkIf config.modules.shell.gopass.enable {
      modules.service.env.PASSWORD_STORE_DIR = config.env.PASSWORD_STORE_DIR;
    })
    (mkIf (config.modules.dev.plugins != []) {
      macos.userScript.initAsdf = {
        desc = "Init asdf ...";
        text = config.modules.dev.text;
      };
    })
  ];
}
