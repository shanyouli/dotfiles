{
  lib,
  config,
  ...
}:
with lib;
with lib.my; {
  imports = [
    ./settings.nix
    ./xdg.nix # @see https://github.com/hlissner/dotfiles/blob/master/modules/xdg.nix
    ./zsh.nix
    ./sysdo.nix
    ./rime.nix
    ./direnv.nix
    ./dev.nix
    ./mpv.nix
    ./asdf.nix
    ./aria2.nix
    ./gopass.nix
    ./python.nix
    ./node.nix
    ./rust.nix
    ./emacs.nix
    ./wezterm.nix
    ./firefox.nix
    ./git.nix
    ./lua.nix
    ./tmux.nix
    ./kitty.nix
    ./nvim.nix
    ./gpg.nix
    ./java.nix
    ./rsync.nix
    ./adb.nix
    ./starship.nix
    ./theme.nix
    ./clash.nix
    ./ytdlp.nix
    ./mpd.nix
    ./sdcv.nix
    ./fzf.nix
    ./mycli.nix
    ./ugrep.nix
    ./nginx.nix
  ];
  my.modules = mkMerge [
    {
      # zsh.starship = false; # using p10k theme
      zsh.enZinit = true;
      zsh.vivid = true;
      dev.enable = true;
      # asdf.enable = true;
      gopass.enable = true;
      python.enable = true;
      node.enable = true;
      rust.enable = true;
      rust.rustup = {
        enable = true;
        # version = "1.56.1";
        rlspEn = false;
      };
      sdcv.enable = true;
      ytdlp.enable = true;
      # emacs.enable = true;
      # aria2.enable = true;
      direnv.enable = true;
      firefox.enable = true;
      git.enable = true;
      git.enGui = true;
      lua.enable = true;
      tmux.enable = true;
      nvim.enable = true;
      # nvim.enGui = true;
      rsync.enable = true;
      theme.enable = true;
      java.enable = true;
      fzf.enable = true;
      mycli.enable = true;
      ugrep.enable = true;
    }
    (mkIf (config.my.terminal == "kitty") {
      kitty.enable = true;
    })
    (mkIf (config.my.terminal == "wezterm") {
      wezterm.enable = true;
    })
  ];
}
