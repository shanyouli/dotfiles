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
  rimeDataPkg =
    if cfg.rime.method == "frost" then
      pkgs.rime-frost
    else if cfg.method == "wanxiang" then
      pkgs.rime-wanxiang
    else
      pkgs.rime-ice;
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
      enable = mkBoolOpt config.modules.rime.enable;
      dir = mkOpt' types.str ".local/share/emacs-rime" "emacs-rime build 缓存内容文件";
      method = mkOpt' types.str config.modules.rime.method "emacs rime method";
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
        overrides = _self: _super: { unstable = pkgs.unstable.emacsPackages; };
        doom.confInit = ''
          ;; (setq mydotfile "/etc/nixos")
        '';
        extraPkgs =
          epkgs:
          [
            epkgs.emacsql
            # epkgs.telega
            epkgs.vterm
            epkgs.eat
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
            #
            epkgs.emt
            epkgs.emacs-reader
          ]
          ++ optionals cfg.rime.enable [
            # epkgs.unstable.rimel
            ((epkgs.unstable.rimel.override { inherit (epkgs.unstable) liberime; }).overrideAttrs (oldAttrs: {
              # 在构建环境中，将 $HOME 指向一个可写入的临时目录
              buildPhase = ''
                export HOME="$TMPDIR"
                runHook preBuild
                ${oldAttrs.buildPhase or ""}
                runHook postBuild
              '';
            }))
            # epkgs.unstable.liberime
          ]
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
          pkgs.texlive.combined.scheme-medium
        ];
        configFile."doom/config.init.el".text = ''
          ;;; config.init.el -*- lexical-binding: t; -*-
          (setq lsp-bridge-python-command "${config.modules.python.finalPkg}/bin/python3")
          ${lib.optionalString pkgs.stdenvNoCC.hostPlatform.isLinux ''
            (setq emt-lib-path "${pkgs.ewt-rs}lib/libewt.so")
          ''}
        ''
        + optionalString cfg.rime.enable (
          let
            rime-data-dir =
              if cfg.rime.method == config.modules.rime.method && config.modules.rime.enable then
                "${config.modules.rime.dataPkg}/share/rime-data"
              else if cfg.rime.method != "" then
                "${rimeDataPkg}/share/rime-data"
              else if pkgs.stdenvNoCC.hostPlatform.isDarwin then
                "/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
              else
                "${pkgs.rime-data}/share/rime-data";
          in
          ''
            (setq liberime-shared-data-dir "${rime-data-dir}")
            (setq liberime-user-data-dir "${config.home.homeDirectory}/${cfg.rime.dir}")
          ''
        )
        + ''
          ${cfg.doom.confInit}
        '';
      };
      my.user.extra = optionalString cfg.rime.enable ''
        log debug "If you updated the emacs-rime input method, delete ${config.home.homeDirectory}/${cfg.rime.dir}/build."
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

            jupyter # jupyter
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
