{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.starship;
  tomlFormat = pkgs.formats.toml {};
  starshipCmd = "${config.home.profileBinDir}/starship";
in {
  options.modules.shell.starship = {
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
    user.packages = [pkgs.starship];
    modules.shell.starship.settings = {
      add_newline = false;
      character = {
        success_symbol = "[[♥](green) ❯](maroon)";
        error_symbol = "[❯](red)";
        vicmd_symbol = "[❮](green)";
      };
      directory = {
        truncation_length = 4;
        # Catppuccin 'lavender'
        style = "bold lavender";
      };
    };
    home.configFile."starship.toml" = mkIf ((cfg.settings != {}) && (config.modules.themes.default == "")) {
      source = tomlFormat.generate "starship-config" cfg.settings;
    };
    programs.bash.interactiveShellInit = mkIf cfg.enableBash ''
      if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
        eval "$(${starshipCmd} init bash --print-full-init)"
      fi
    '';
  };
}
