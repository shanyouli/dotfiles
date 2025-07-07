{
  config,
  pkgs,
  lib,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.app.editor.emacs;
  emacsPackages =
    let
      epkgs = pkgs.emacsPackagesFor cfg.package;
    in
    # epkgs.overrideScope' cfg.overrides;
    epkgs.overrideScope cfg.overrides;
  inherit (emacsPackages) emacsWithPackages;
in
{
  options.modules.app.editor.emacs = {
    enable = mkBoolOpt false;

    service = {
      enable = mkBoolOpt cfg.enable;
      startup = mkBoolOpt true;
      keep = mkBoolOpt true;
    };
    rime = {
      ice.enable = mkBoolOpt false; # 目前由于性能原因，不推荐使用万象拼音。
      enable = mkBoolOpt config.modules.rime.enable;
      dir = mkOpt' types.str ".local/share/emacs-rime" "emacs-rime build 缓存内容文件";
    };

    doom = {
      enable = mkBoolOpt true;
      fromSSH = mkBoolOpt false;
      pkg = {
        prefer = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = "TODO";
        };
        disable = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = "TODO";
        };
      };
      confInit = mkOpt' types.lines "" ''
        Conf Lines to be written to $XDG_CONFIG_HOME/doom/config.init.el and
        loaded by $XDG_CONFIG_HOME/doom/config.el
      '';
    };
    extraPkgs = mkOption {
      default = _self: [ ];
      type = selectorFunction;
      defaultText = "epkgs: []";
      example = literalExpression "epkgs: [epkgs.emms epkgs.magit ]";
      description = ''
        Extra packages available to Emacs. To get a list of
        available packages run:
        <command>nix-env -f '&lt;nixpkgs&gt;' -qaP -A emacsPackages</command>.
      '';
    };
    overrides = mkOption {
      default = _self: _super: { };
      type = overlayFunction;
      defaultText = "self: super: {}";
      example = literalExpression ''
        self: super: rec {
          haskell-mode = self.melpaPackages.haskell-mode;
          # ...
        };
      '';
      description = ''
        Allows overriding packages within the Emacs package set.
      '';
    };
    package = mkOption {
      type = types.package;
      default = pkgs.emacs;
      defaultText = literalExpression "pkgs.emacs";
      example = literalExpression "pkgs.emacs26-nox";
      description = "The Emacs Package to use.";
    };
    pkg = mkPkgReadOpt "The emacs include overrides and plugins";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.app.editor.emacs = {
        doom.confInit = ''
          ;; (setq mydotfile "/etc/nixos")
        '';
        extraPkgs =
          epkgs:
          [
            epkgs.emacsql
            # epkgs.telega
            epkgs.vterm
            epkgs.pdf-tools
            epkgs.saveplace-pdf-view

            epkgs.puni
            epkgs.ef-themes
            epkgs.rainbow-mode
            epkgs.noflet
            # (epkgs.treesit-grammars.with-grammars
            #   (grammars:
            #     with grammars; [
            #       tree-sitter-bash
            #     ]))
            epkgs.treesit-grammars.with-all-grammars
            epkgs.elvish-mode
          ]
          ++ optionals cfg.rime.enable [ epkgs.rime ]
          ++ optionals config.modules.just.enable [
            epkgs.just-mode
            epkgs.justl
          ]
          ++ optionals config.modules.shell.nushell.enable [ epkgs.nushell-ts-mode ];
        pkg = emacsWithPackages cfg.extraPkgs;
      };
    }
    {
      home = {
        packages = [
          cfg.pkg

          pkgs.graphviz
          pkgs.pandoc

          #dirvish 包需要的工具
          # poppler
          pkgs.ffmpegthumbnailer
          pkgs.mediainfo
          # grip markdown 预览配置
          pkgs.python3Packages.grip

          pkgs.emacs-lsp-booster # emacs-lsp-booster , 更快的使用 lsp 服务

          (mkIf config.modules.gpg.enable pkgs.pinentry-emacs) # in emacs gnupg prompts
        ];
        configFile."doom/config.init.el".text =
          ''
            ;;; config.init.el -*- lexical-binding: t; -*-
            (setq lsp-bridge-python-command "${config.modules.python.finalPkg}/bin/python3")
          ''
          + optionalString cfg.rime.enable (
            let
              rime-data-dir =
                if cfg.rime.ice.enable then
                  "${pkgs.unstable.rime-ice}/share/rime-data"
                else if config.modules.rime.enable then
                  "${config.modules.rime.dataPkg}/share/rime-data"
                else if pkgs.stdenvNoCC.hostPlatform.isDarwin then
                  "/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
                else
                  "${pkgs.rime-data}/share/rime-data";
            in
            ''
              (setq rime-emacs-module-header-root "${cfg.package}/include")
              (setq rime-librime-root "${pkgs.librime}")
              (setq rime-share-data-dir "${rime-data-dir}")
              (setq rime-user-data-dir "${my.homedir}/${cfg.rime.dir}")
            ''
          )
          + ''
            ${cfg.doom.confInit}
          '';
      };
      my.user.extra = optionalString cfg.rime.enable ''
        log debug "If you updated the emacs-rime input method, delete ${my.homedir}/${cfg.rime.dir}/build."
      '';
      modules = {
        python.extraPkgs =
          ps: with ps; [
            epc
            orjson
            six
            paramiko
            rapidfuzz
            sexpdata # 0.0.3, or lsp-bridge
            watchdog
          ];
        shell = {
          env = {
            PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];
            GRIPHOME = "$XDG_CONFIG_HOME/grip";
          };
          zsh.pluginFiles = [ "emacs" ];
          nushell.scriptFiles = [ "emacs" ];
        };
      };
    }
  ]);
}
