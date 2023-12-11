{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.starship;
  tomlFormat = pkgs.formats.toml {};
  starshipCmd = "${config.my.hm.profileDirectory}/bin/starship";
in {
  options.modules.starship = {
    enable = mkBoolOpt false;

    settings = mkOption {
      type = with types; let
        prim = either bool (either int str);
        primOrPrimAttrs = either prim (attrsOf prim);
        entry = either prim (listOf primOrPrimAttrs);
        entryOrAttrsOf = t: either entry (attrsOf t);
        entries = entryOrAttrsOf (entryOrAttrsOf entry);
      in
        attrsOf entries // {description = "Starship configuration";};
      default = {};
      example = literalExpression ''
        {
          add_newline = false;
          format = lib.concatStrings [
            "$line_break"
            "$package"
            "$line_break"
            "$character"
          ];
          scan_timeout = 10;
          character = {
            success_symbol = "➜";
            error_symbol = "➜";
          };
        }
      '';
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/starship.toml</filename>.
        </para><para>
        See <link xlink:href="https://starship.rs/config/" /> for the full list
        of options.
      '';
    };
    enableBash = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    my.user.packages = [pkgs.starship];
    my.hm.configFile."starship.toml" =
      if (cfg.settings != {})
      then {
        source = let
          default =
            builtins.fromTOML
            (builtins.readFile "${configDir}/starship/starship.toml");
          allSettings = default // cfg.settings;
        in
          tomlFormat.generate "starship-config" allSettings;
      }
      else {
        source = "${configDir}/starship/starship.toml";
      };
    programs.bash.interactiveShellInit = mkIf cfg.enableBash ''
      if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
        eval "$(${starshipCmd} init bash --print-full-init)"
      fi
    '';
  };
}
