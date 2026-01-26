{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules.shell.prompt;
  cfg = cfm.starship;
in
{
  options.modules.shell.prompt.starship = {
    enable = mkBoolOpt false;

    settings = mkOption {
      type =
        with types;
        let
          prim = either bool (either int str);
          primOrPrimAttrs = either prim (attrsOf prim);
          entry = either prim (listOf primOrPrimAttrs);
          entryOrAttrsOf = t: either entry (attrsOf t);
          entries = entryOrAttrsOf (entryOrAttrsOf entry);
        in
        attrsOf entries // { description = "Starship configuration"; };
      default = { };
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
  };
  config = mkIf cfg.enable {
    home = {
      packages = [ pkgs.starship ];
      programs.bash.initExtra = lib.optionalString cfm.bash.enable ''
        eval `starship init bash --print-full-init`
      '';
      configFile."starship.toml" = mkIf (cfg.settings != { }) { source = toTomlFile cfg.settings; };
    };
    modules.shell = {
      prompt.starship.settings = {
        add_newline = false;
        character = {
          success_symbol = "[[♥](green) ❯](maroon)";
          error_symbol = "[❯](red)";
          vicmd_symbol = "[❮](green)";
        };
        directory = {
          truncation_length = 4;
          style = "bold lavender";
        };
      };
      zsh.rcInit = lib.optionalString cfm.zsh.enable ''
        _cache starship init zsh --print-full-init
      '';
      nushell.cacheCmd = [ "${pkgs.starship}/bin/starship init nu" ];
      fish.rcInit = optionalString cfm.fish.enable ''_cache starship init fish --print-full-init'';
    };
  };
}
