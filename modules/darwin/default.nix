{config, ...}: {
  config.imports = [
    ../common.nix
    # ./settings.nix
    # ./homebrew.nix
    # ./asdf.nix
    # ./core.nix
    # ./macos.nix
    # ./music.nix
    # ./games.nix
    # ./services.nix
    # ./yabai.nix
    # ./emacs.nix
    # ./aria2.nix
    # ./hammerspoon.nix
    # ./alist.nix
    # ./mosdns.nix
    # ./clash.nix
    # ./mpd.nix
    # ./rime.nix
    # ./iina.nix
    # ./battery.nix
    # ./nginx.nix
    # ./other.nix
  ];
  config.macos.systemScript.removeNixApps = {
    enable = true;
    text = ''
      if [[ -e '/Applications/Nix Apps' ]]; then
        $DRY_RUN_CMD rm -rf '/Applications/Nix Apps'
      fi
    '';
    desc = "Remove /Applications/Nix\ Apps";
  };
  config.macos.systemScript.zshell = {
    enable = true;
    text = ''
      chsh -s /run/current-system/sw/bin/zsh ${config.my.username}
    '';
    desc = "setting Default Shell";
  };
  config.macos.userScript.clear_zsh = {
    enable = true;
    text = ''
      if [[ -d ${config.env.ZSH_CACHE}/cache ]]; then
        $DRY_RUN_CMD rm -rf ${config.env.ZSH_CACHE}/cache
      fi
      command -v bat >/dev/null && bat cache --build >/dev/null

      # 禁止在 USB 卷创建元数据文件, .DS_Store
      defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
      # 禁止在网络卷创建元数据文件
      defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    '';
    desc = "clear zsh ";
  };
}
