{
  lib,
  config,
  pkgs,
  options,
  myvars,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.theme.catppuccin;
  cm = config.modules;
  themes = ["mocha" "latte" "macchiato" "frappe"];
  fzf = {
    macchiato = ''
      export FZF_DEFAULT_OPTS=" \
        --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
        --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
        --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
    '';
    mocha = ''
      export FZF_DEFAULT_OPTS=" \
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    '';
    latte = ''
      export FZF_DEFAULT_OPTS=" \
        --color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \
        --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \
        --color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"
    '';
    frappe = ''
      export FZF_DEFAULT_OPTS=" \
        --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
        --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
        --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"
    '';
  };
  configDir = "${myvars.dotfiles.config}/themes/catppuccin";
  configPath = ".cache/themes/catppucin";
  linkDir = "${myvars.homedir}/${configPath}";
  defaultDir = "${myvars.homedir}/.cache/themes/default";
in {
  # https://github.com/catppuccin
  options.modules.theme.catppuccin = {
    enable = mkBoolOpt false;
    name = mkStrOpt "mocha";
    light = mkStrOpt "latte";
    dark = mkStrOpt "macchiato";
    texts = mkOpt' types.attrs {} "texts by str";
    dirs = mkOpt' types.attrs {} "Files by path";
  };
  config = mkIf cfg.enable {
    modules = {
      theme = {
        script =
          ''
            if [[ -d "${defaultDir}" ]]; then
              rm -rf "${defaultDir}"
            fi
            ln -sf "${linkDir}/${cfg.name}" "${defaultDir}"
          ''
          + optionalString cm.modern.enable ''
            echo-info "Handling bat theme management..."
            [[ -d "${config.home.configDir}/bat/themes" ]] || mkdir -p "${config.home.configDir}/bat/themes"
            ln -sf "${defaultDir}/bat.tmTheme"  "${config.home.configDir}/bat/themes/catppuccin.tmTheme"
            command -v bat >/dev/null && bat cache --build >/dev/null
          ''
          + optionalString cm.app.editor.helix.enable ''
            echo-info "Handling helix theme management..."
            [[ -d "${config.home.configDir}/helix/themes" ]] || mkdir -p "${config.home.configDir}/helix/themes"
            ln -sf "${defaultDir}/helix.toml"  "${config.home.configDir}/helix/themes/catppuccin.toml"
          '';
        catppuccin = {
          texts = builtins.listToAttrs (map (n: {
              name = n;
              value = {
                zshrc = ''
                  #!/usr/bin/env zsh
                  ${lib.optionalString cm.shell.vivid.enable ''
                    export LS_COLORS=$(${pkgs.vivid.out}/bin/vivid generate catppuccin-${n})
                  ''}
                  if [[ -z $INSIDE_EMACS ]]; then
                    ${fzf."${n}"}
                  fi
                  ${lib.optionalString cm.shell.prompt.starship.enable ''
                    export STARSHIP_CONFIG="${defaultDir}/starship.toml"
                  ''}
                '';
                "tmux" = optionalString cm.tmux.enable ''
                  set -g @catppuccin_flavour '${n}'
                  run-shell '${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux'
                '';
              };
            })
            themes);
          dirs = builtins.listToAttrs (map (n: {
              name = n;
              value = {
                "kitty.conf" = optionalString config.modules.gui.terminal.kitty.enable "${configDir}/kitty/${n}.conf";
                "bat.tmTheme" = "${configDir}/bat/Catppuccin-${n}.tmTheme";
                "helix.toml" = optionalString cm.app.editor.helix.enable "${configDir}/helix/${n}.toml";
                "starship.toml" = optionalString cm.shell.prompt.starship.enable (let
                  colors = builtins.fromTOML (builtins.readFile "${configDir}/starship/${n}.toml");
                  allSettings =
                    cm.shell.prompt.starship.settings
                    // {
                      palettes.${n} = colors;
                      palette = "${n}";
                    };
                  result = let
                    tomlFormat = pkgs.formats.toml {};
                  in
                    tomlFormat.generate "starship-config" allSettings;
                in "${result}");
              };
            })
            themes);
        };
      };
      shell = {
        zsh.envInit = ''
          export BAT_THEME='catppuccin'
        '';
        zsh.prevInit = ''
          _source "${defaultDir}/zshrc"
        '';
      };

      gui.terminal.kitty.settings = ''
        include ${defaultDir}/kitty.conf
      '';
      tmux.rcFiles = mkBefore ["${defaultDir}/tmux"];

      app.editor.helix.settings.theme = "catppuccin";
    };
    home.file = let
      filterFn = _: v: v != "";
      texts_fn = n:
        concatMapAttrs (name: value: {"${configPath}/${n}/${name}".text = value;})
        (filterAttrs filterFn cfg.texts.${n});
      dirs_fn = n:
        concatMapAttrs (name: value: {"${configPath}/${n}/${name}".source = value;})
        (filterAttrs filterFn cfg.dirs.${n});
    in
      mergeAttrs' ((map texts_fn themes) ++ (map dirs_fn themes));
  };
}
