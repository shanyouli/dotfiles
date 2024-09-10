{
  lib,
  system,
  ...
}: let
  inherit (lib) optionals findFirst pathExists removePrefix;
  isDarwin = system: builtins.elem system lib.platforms.darwin;
  # default "lyeli"
  name = let
    envUser = builtins.getEnv "USER";
  in
    if builtins.elem envUser ["" "root"]
    then "lyeli"
    else envUser;
  homedir =
    if isDarwin system
    then "/Users/${name}"
    else "/home/${name}";

  dotDefault = let
    envDotfiles = builtins.getEnv "DOTFILES";
    defaultPath = builtins.toString ../.;
    dotfilesList =
      []
      ++ optionals (envDotfiles != "") [envDotfiles]
      ++ [
        "/mnt/etc/dotfiles"
        "/etc/dotfiles"
        "/mnt/etc/nixos"
        "/etc/nixos"
        "${homedir}/.config/dotfiles"
        "${homedir}/.dotfiles"
        "${homedir}/.nixpkgs"
      ];
  in
    removePrefix "/mnt" (findFirst pathExists defaultPath dotfilesList);
in rec {
  inherit homedir;
  user = name;
  fullName = "Shanyou Li";
  useremail = "shanyouli6@gmail.com";
  website = "https://shanyouli.github.io";
  timezone = "Asia/Shanghai";

  dotfiles = {
    dir = dotDefault;
    config = "${dotDefault}/config";
    bin = "${dotDefault}/bin";
    modules = "${dotDefault}/modules";
  };
}
