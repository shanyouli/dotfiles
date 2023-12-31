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
    modules.editor.vscode.extensions = [pkgs.unstable.vscode-extensions.mkhl.direnv];
    home.configFile = mkMerge [
      (mkIf (config.modules.dev.plugins != []) {
        "direnv/lib/use_asdf.sh".source = "${config.dotfiles.configDir}/direnv/lib/use_asdf.sh";
      })
      (mkIf config.modules.dev.python.enable {
        "direnv/lib/use_poetry.sh".source = "${config.dotfiles.configDir}/direnv/lib/use_poetry.sh";
      })
      {
        "direnv/direnvrc".text = ''
          source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
        '';
      }
    ];
  };
}
