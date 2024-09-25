{
  lib,
  config,
  options,
  pkgs,
  my,
  ...
}:
with lib;
with my; let
  cfm = config.modules;
  cfg = cfm.shell.nix-index;
  cfgpkg = pkgs.unstable.my.nix-index;
in {
  options.modules.shell.nix-index = {
    enable = mkEnableOption "Whether to nix-index";
  };
  config = mkIf cfg.enable {
    home.programs.nix-index = {
      enable = true;
      package = cfgpkg;
      enableBashIntegration = true;
      # package = inputs.nurpkgs.currentSystem.packages.nix-index;
    };
    modules.shell.zsh.rcInit = ''
      _source ${cfgpkg}/etc/profile.d/command-not-found.sh
    '';
    modules.shell.nushell.rcInit = ''
      $env.config = ($env | default {} config).config
      $env.config.hooks = ($env.config | default {} hooks).hooks
      $env.config.hooks.command_not_found = {|cmd_name|
          try {
              let attrs = (${cfgpkg}/bin/nix-locate --minimal --no-group --type x --type s --top-level --whole-name --at-root $"/bin/($cmd_name)" | lines)
              if ($attrs | is-empty) {
                  if (which brew | is-empty) {
                      return null
                  } else {
                      return (brew which-formula --explain $cmd_name)
                  }
              } else {
                  let out = ($attrs | each { |x| $x | str replace ".out" ""} | str join ", ")
                  return $"\nThe program ($cmd_name) is not installed, but available from the following location\(s\):\n\n($out)"
              }
          }
      }
    '';
  };
}
