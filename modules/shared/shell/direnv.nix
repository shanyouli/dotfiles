{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.direnv;
in {
  options.modules.shell.direnv = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = [pkgs.direnv pkgs.nix-direnv];
    modules.shell.rcInit = ''_cache direnv hook zsh'';
    my.hm.configFile = mkMerge [
      (mkIf (config.modules.dev.plugins != []) {
        "direnv/lib/use_asdf.sh".source = "${configDir}/direnv/lib/use_asdf.sh";
      })
      (mkIf config.modules.dev.python.enable {
        "direnv/lib/use_poetry.sh".source = "${configDir}/direnv/lib/use_poetry.sh";
      })
      {
        "direnv/direnvrc".text = ''
          source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
        '';
      }
    ];
  };
}
