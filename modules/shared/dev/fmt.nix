# markdown see@https://github.com/rvben/rumdl
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
  cfp = config.modules.dev;
  cfg = cfp.fmt;
in
{
  options.modules.dev.fmt = {
    toml.enable = mkEnableOption "Whether to enable format toml";
    biome.enable = mkEnableOption ''
      Whether to use biome format jsonc, json, ts, js, css, html.
      @see https://www.biomejs.cn/internals/language-support
    '';
    js-beautify.enable = mkEnableOption ''
      Whether or not to format js files with js-beautify
    '';
    python.enable = mkEnableOption "Whether or not to format python with ruff";
    bash.enable = mkEnableOption "Whether to format bash file by shfmt";
    lua.enable = mkEnableOption "Whether to format lua file by stylua";
    fennel.enable = mkEnableOption "Whether to format fennel file by fnlmt";
    nix.enable = mkEnableOption "Whether to format nix file by nixfmt";
    markdown.enable = mkEnableOption "Whether to format markdown file by rumdl";
  };
  config = mkMerge [
    {
      modules.dev.fmt = {
        python.enable = mkDefault cfp.python.enable;
        bash.enable = mkDefault cfp.bash.enable;
        lua.enable = mkDefault cfp.lua.enable;
        fennel.enable = mkDefault cfp.lua.fennel.enable;
        nix.enable = mkDefault cfp.nix.enable;
      };
    }
    (mkIf cfg.toml.enable { home.packages = [ pkgs.taplo ]; })
    (mkIf cfg.biome.enable {
      home.packages = [ pkgs.biome ];
      modules.shell.env.BIOME_CONFIG_PATH = "$XDG_CONFIG_HOME/biome/biome.jsonc";
      home.configFile."biome/biome.jsonc".text = builtins.toJSON {
        "$schema" = "${pkgs.biome}/share/schema.json";
        formatter = {
          indentStyle = "space";
          lineWidth = 100;
        };
      };
    })
    (mkIf cfg.bash.enable { home.packages = [ pkgs.shfmt ]; })
    (mkIf cfg.lua.enable { home.packages = [ pkgs.stylua ]; })
    (mkIf cfg.fennel.enable { home.packages = [ pkgs.fnlfmt ]; })
    (mkIf cfg.python.enable { home.packages = [ pkgs.ruff ]; })
    (mkIf cfg.nix.enable { home.packages = [ pkgs.nixfmt ]; })
    (mkIf cfg.js-beautify.enable { home.packages = [ pkgs.js-beautify ]; })
    (mkIf cfg.markdown.enable { home.packages = [ pkgs.rumdl ]; })
  ];
}
