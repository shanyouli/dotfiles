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
        "echo '${enableText.desc}' "}
      ${enableText.text}
    '') (sortFn (lib.filter filterLambda attrList));
  userScripts = pkgs.writeScript "postUserScript" ''
    #!${pkgs.stdenv.shell}
    export PATH=/usr/bin:$PATH
    ${filterEnabledTexts cfg.userScript}
  '';
  systemScripts = pkgs.writeScript "postSystemScript" ''
    #!${pkgs.stdenv.shell}
    export PATH=/usr/bin:$PATH
    ${filterEnabledTexts cfg.systemScript}
  '';
in {
  options.macos = with types; {
    userScript = mkOpt attrs {};
    systemScript = mkOpt attrs {};
  };
  config = {
    my.enGui = true;
    system.activationScripts.postActivation.text = ''
      echo "System script executed after system activation"
      ${systemScripts}
      sudo -u ${config.my.username} --set-home ${userScripts}
    '';
    macos.systemScript.removeNixApps = {
      enable = true;
      text = ''
        if [[ -e '/Applications/Nix Apps' ]]; then
          $DRY_RUN_CMD rm -rf '/Applications/Nix Apps'
        fi
      '';
      desc = "Remove /Applications/Nix\ Apps ...";
    };
    macos.systemScript.zshell = {
      enable = true;
      text = ''
        chsh -s /run/current-system/sw/bin/zsh ${config.my.username}
      '';
      desc = "setting Default Shell";
    };
    macos.userScript.clear_zsh = {
      enable = true;
      text = ''
        echo "Clear zsh ..."
        if [[ -d ${config.env.ZSH_CACHE}/cache ]]; then
          $DRY_RUN_CMD rm -rf ${config.env.ZSH_CACHE}/cache
        fi
        command -v bat >/dev/null && bat cache --build >/dev/null

        # 禁止在 USB 卷创建元数据文件, .DS_Store
        defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
        # 禁止在网络卷创建元数据文件
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
      '';
    };
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
  };
}
