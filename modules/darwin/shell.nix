{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my; let
  env-paths = pkgs.runCommandLocal "env-paths" {} (let
    profilePath = makeBinPath (builtins.filter (x: x != "/nix/var/profiles/default") config.environment.profiles);
    configEnvPath =
      if builtins.hasAttr "PATH" config.env
      then config.env.PATH
      else null;
    prevPath =
      if (configEnvPath != null)
      then config.env.PATH + ":" + profilePath
      else profilePath;
    baseOut = ''
      echo "PATH=$PATH;" > $out
    '';
    printOuts =
      if config.modules.macos.brew.enable
      then ''
        if [[ -x ${config.homebrew.brewPrefix}/brew ]]; then
          ${config.homebrew.brewPrefix}/brew shellenv bash > $out
        else
          ${baseOut}
        fi
      ''
      else baseOut;
  in ''
    PATH=""
    if [ -x /usr/libexec/path_helper ]; then
      eval $(/usr/libexec/path_helper -s)
    else
      PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
    fi
    ${printOuts}
    echo 'PATH=${prevPath}''${PATH:+:}$PATH; export PATH' >> $out
  '');
in {
  config = {
    environment = mkMerge [
      {
        profiles = mkOrder 800 ["${config.home.stateDir}/nix/profile"];
        extraInit = mkOrder 100 ". ${env-paths}\n";
      }
      (mkIf config.modules.shell.fish.enable {
        etc."fish/nixos-env-preinit.fish".text = mkMerge [
          (lib.mkBefore ''
            set -g __nixos_path_original $PATH
          '')
          (lib.mkAfter ''
            function __nixos_path_fix -d "fix PATH value"
            set -l result (string replace '$HOME' "$HOME" $__nixos_path_original)
            for elt in $PATH
              if not contains -- $elt $result
                set -a result $elt
              end
            end
            set -g PATH $result
            end
          '')
        ];
      })
    ];
    programs = {
      bash.interactiveShellInit = ''
        # /etc/profile 的执行导致 bash 中 PATH 出现问题，这里重新声明 PATH
        . ${env-paths}
      '';
      fish.shellInit = ''
        __nixos_path_fix
      '';
    };
  };
}
