{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.macos;
  filterEnabledTexts = dict: let
    attrList = lib.attrValues dict;
    filterLambda = x:
      if builtins.hasAttr "enable" x
      then x.enable
      else false;
    sortLambda = x: y: let
      levelx =
        if builtins.hasAttr "level" x
        then x.level
        else 50;
      levely =
        if builtins.hasAttr "level" y
        then y.level
        else 50;
    in
      levelx < levely;
    sortFn = la: pkgs.lib.sort sortLambda la;
  in
    lib.concatMapStrings (enableText: ''
      ${lib.optionalString (hasAttr "desc" enableText)
        "echo '${enableText.desc}' "}
      ${enableText.text}
    '') (sortFn (lib.filter filterLambda attrList));
  userScripts = pkgs.writeScript "postUserScript" ''
    #!${pkgs.stdenv.shell}
    ${filterEnabledTexts cfg.userScript}
  '';
  systemScripts = pkgs.writeScript "postSystemScript" ''
    #!${pkgs.stdenv.shell}
    ${filterEnabledTexts cfg.systemScript}
  '';
in {
  options.macos = with types; {
    userScript = mkOpt attrs {};
    systemScript = mkOpt attrs {};
  };
  config = {
    system.activationScripts.postActivation.text = ''
      echo "System script executed after system activation"
      ${systemScripts}
      sudo -u ${config.my.username} --set-home ${userScripts}
    '';
  };
}
