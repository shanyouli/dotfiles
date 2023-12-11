{
  config,
  pkgs,
  lib,
  options,
  inputs,
  ...
}:
with lib;
with lib.my; let
  homeDir = config.my.hm.dir;
  rustup_dir = "${homeDir}/.local/share/rustup";

  cfg = config.modules.rust;
in {
  options.modules.rust = with types; {
    enable = mkBoolOpt false;
    cargoScript = mkStrOpt "";
    rustup = {
      enable = mkBoolOpt false;
      version = mkStrOpt "stable"; # 默认安装的rust版本
      rlspEn = mkBoolOpt true;
      script = mkStrOpt "";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.rustup.enable {
      my.user.packages = with pkgs; [rustup (mkIf cfg.rustup.rlspEn rust-analyzer)];
      modules.zsh.env.RUSTUP_HOME = rustup_dir;
      #TODO: rustup install stable and rust-analyzer
      modules.rust.rustup.script =
        ''
          export RUSTUP_HOME=${rustup_dir}

          _version="${cfg.rustup.version}"
          if [ "$(${pkgs.rustup}/bin/rustup toolchain list | grep -i $_version )" != "" ]; then
              echo "rust 版本已存在"
          else
              ${pkgs.rustup}/bin/rustup toolchain install $_version --component rust-src
              ${pkgs.rustup}/bin/rustup default $_version
          fi
        ''
        + optionalString (!cfg.rustup.rlspEn) ''
          echo "开始安装 rust-analyzer"
          if [[ -f ${config.my.hm.binHome}/rust-analyzer ]]; then
              echo "rust-analyzer 已被安装"
          elif [ "$(${pkgs.rustup}/bin/rustup component list | grep -i rust-analyzer )" != "" ]; then
              ${pkgs.rustup}/bin/rustup component add rust-analyzer
              ln -st ${config.my.hm.binHome} $(${pkgs.rustup}/bin/rustup which rust-analyzer)
          else
              echo "warn: rust版本过低"
              echo "warn: 请手动安装rust-analyzer"
          fi
        '';
    })
    (mkIf (!cfg.rustup.enable) {
      nixpkgs.overlays = [inputs.rust-overlay.overlays.default];
      my.user.packages = with pkgs; [
        (rust-bin.stable.latest.default.override {
          extensions =
            []
            ++ optionals config.modules.dev.enable [
              "rust-src"
              "rust-analyzer"
            ];
        })
      ];
    })
    {
      my = {
        user.packages = with pkgs; [cargo-update];
      };
      modules.zsh = {
        env = {
          CARGO_HOME = let
            cargoConfig = ''
              [source.crates-io]
              registry = "https://github.com/rust-lang/crates.io-index"
              replace-with = 'ustc'
              [source.ustc]
              registry = "git://mirrors.ustc.edu.cn/crates.io-index"
              [registries.ustc]
              index = "git://mirrors.ustc.edu.cn/crates.io-index"

              [install]
              root = "${homeDir}/.local"
              [build]
              target-dir = "${config.my.hm.cacheHome}/cargo/target"
            '';
          in "${pkgs.runCommandLocal "cargo-home" {inherit cargoConfig;} ''
            mkdir -p $out
            ln -st $out "${config.my.hm.cacheHome}"/cargo/{registry,git}
            ln -st $out "${config.my.hm.configHome}"/cargo/credentials.toml
            echo -n "$cargoConfig" >$out/config.toml
          ''}";
        };
        aliases = {
          up_cargo = "cargo install-update -a";
          rs = "rustc";
          rsp = "rustup";
          ca = "cargo";
        };
      };
      modules.rust.cargoScript = ''
        $DRY_RUN_CMD mkdir -p "${homeDir}"/{.config/cargo,.cache/cargo/{registry,git}}
        $DRY_RUN_CMD touch -a "${homeDir}"/.config/cargo/credentials.toml
      '';
    }
  ]);
}
