{
  self,
  lib,
  system,
  ...
}:
let
  inherit (lib)
    optionals
    findFirst
    pathExists
    removePrefix
    ;
  # default "lyeli"
  name =
    let
      envUser = builtins.getEnv "USER";
    in
    if
      builtins.elem envUser [
        ""
        "root"
      ]
    then
      "lyeli"
    else
      envUser;
  homeDir = if self.my.isDarwin system then "/Users/${name}" else "/home/${name}";

  dotDefault =
    let
      envDotfiles = builtins.getEnv "DOTFILES";
      defaultPath = builtins.toString ../../.;
      dotfilesList = optionals (envDotfiles != "") [ envDotfiles ] ++ [
        "/mnt/etc/dotfiles"
        "/etc/dotfiles"
        "/mnt/etc/nixos"
        "/etc/nixos"
        "${homeDir}/.config/dotfiles"
        "${homeDir}/.dotfiles"
        "${homeDir}/.nixpkgs"
      ];
    in
    removePrefix "/mnt" (findFirst pathExists defaultPath dotfilesList);
in
rec {
  vars = {
    user = name;
    fullName = "Shanyou Li";
    useremail = "shanyouli6@gmail.com";
    website = "https://shanyouli.github.io";
    timezone = "Asia/Shanghai";
  };

  paths = {
    homedir = homeDir;
    dotfiles = {
      dir = dotDefault;
      config = "${dotDefault}/config";
      bin = "${dotDefault}/bin";
      modules = "${dotDefault}/modules";
    };
  };

  inherit (vars)
    user
    fullName
    useremail
    website
    timezone
    ;
  inherit (paths) homedir dotfiles;
}
