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
    profilePath = makeBinPath (builtins.filter (x: x != "/nix/var/nix/profiles/default") config.environment.profiles);
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
    environment = {
      profiles = mkOrder 800 ["${config.home.stateDir}/nix/profile"];
      extraInit = mkOrder 100 ". ${env-paths}\n";
    };
    programs = {
      bash.interactiveShellInit = ''
        # /etc/profile 的执行导致 bash 中 PATH 出现问题，这里重新声明 PATH
        . ${env-paths}
      '';
      fish.shellInit = let
        fenv = pkgs.fishPlugins.foreign-env or pkgs.fish-foreign-env;
        # fishPlugins.foreign-env and fish-foreign-env have different function paths
        fenvFunctionsDir =
          if (pkgs ? fishPlugins.foreign-env)
          then "${fenv}/share/fish/vendor_functions.d"
          else "${fenv}/share/fish-foreign-env/functions";
      in ''
        set fish_function_path ${fenvFunctionsDir} $fish_function_path
        fenv source ${env-paths}
        set -e fish_function_path[1]
      '';
    };
  };
}
