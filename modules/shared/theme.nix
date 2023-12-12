{
  lib,
  config,
  pkgs,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.theme;
  cm = config.modules;
in {
  options.modules.theme = {
    enable = mkBoolOpt false;
    # https://github.com/catppuccin
    name = mkStrOpt "mocha";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.shell.rcInit = ''
        BAT_THEME="Catppuccin-${cfg.name}"
      '';
    }
    (mkIf cm.shell.enVivid {
      modules.shell.envInit = ''
        export LS_COLORS=$(${pkgs.vivid.out}/bin/vivid generate catppuccin-${cfg.name})
      '';
    })
    (mkIf cm.shell.starship.enable {
      modules.shell.starship.settings.palette = "catppuccin_${cfg.name}";
    })
    (mkIf cm.nvim.enable {
      my.hm.configFile."nvim/lua/plugins/usetheme.lua".text = ''
        return {
          {
            "LazyVim/LazyVim",
            opts = {
              colorscheme = "catppuccin-${cfg.name}",
            },
          },
        }
      '';
    })
    (mkIf config.modules.kitty.enable {
      modules.kitty.settings = ''
        include themes/${cfg.name}.conf
      '';
    })
    (mkIf cm.shell.fzf.enable (let
      fzftheme =
        if cfg.name == "macchiato"
        then ''
          export FZF_DEFAULT_OPTS=" \
            --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
            --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
            --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
        ''
        else if cfg.name == "mocha"
        then ''
          FZF_DEFAULT_OPTS=" \
            --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
            --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
            --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
        ''
        else if cfg.name == "latte"
        then ''
          FZF_DEFAULT_OPTS=" \
            --color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \
            --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \
            --color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"
        ''
        else ''
          FZF_DEFAULT_OPTS=" \
            --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
            --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
            --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"
        '';
    in {
      modules.shell.rcInit = ''
        if [[ -z $INSIDE_EMACS ]]; then
           ${fzftheme}
        fi
      '';
    }))
  ]);
}
