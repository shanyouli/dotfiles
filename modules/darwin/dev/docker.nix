{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.dev.docker;
in
{
  options.modules.macos.dev.docker = {
    enable = mkEnableOption "Whether to use docker";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [
      "orbstack" # docker
    ];
    modules.shell.zsh.rcInit = ''
      zinit ice as"completion" # has"docker"
      zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker
    '';
  };
}
