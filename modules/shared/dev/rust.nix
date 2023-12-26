{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.dev.rust;
  homeDir = config.user.home;
  rustup_dir = "${homeDir}/.local/share/rustup";
  package = pkgs.unstable.rustup;
in {
  options.modules.dev.rust = {
    enable = mkEnableOption "Whether to dev rust";
    enSlsp = mkEnableOption "Whether to use system rust-lsp";
    version = mkStrOpt "stable";
    initScript = mkOpt' types.lines "" "init script";
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs.unstable; [
      package
      (mkIf cfg.enSlsp rust-analyzer)
      cargo-update
    ];
    modules.shell.env.RUSTUP_HOME = rustup_dir;
    modules.shell.env.CARGO_HOME = let
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
    modules.shell.aliases = {
      up_cargo = "cargo install-update -a";
      rs = "rustc";
      rsp = "rustup";
      ca = "cargo";
    };
    modules.dev.rust.initScript =
      ''
        $DRY_RUN_CMD mkdir -p "${homeDir}"/{.config/cargo,.cache/cargo/{registry,git}}
        $DRY_RUN_CMD touch -a "${homeDir}"/.config/cargo/credentials.toml
        export RUSTUP_HOME=${rustup_dir}
        _version="${cfg.version}"
        if [ "$(${package}/bin/rustup toolchain list | grep -i $_version )" != "" ]; then
          echo "rust alread installed."
        else
          ${package}/bin/rustup toolchain install $_version --component rust-src
          ${package}/bin/rustup default $_version
        fi
      ''
      + optionalString (!cfg.enSlsp) ''
        if [[ -f ${config.my.hm.binHome}/rust-analyzer ]]; then
            echo "rust-analyzer alread installed."
        elif [ "$(${package}/bin/rustup component list | grep -i rust-analyzer )" != "" ]; then
             echo "start Install rust-analyzer"
            ${package}/bin/rustup component add rust-analyzer
            [[ -f "${config.my.hm.binHome}/rust-analyzer" ]] || \
              ln -st ${config.my.hm.binHome} $(${package}/bin/rustup which rust-analyzer)
        else
            echo "warn: Low version of rust"
            echo "warn: Please use cargo install or system command to install it"
        fi
      '';
  };
}
