{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfm = config.modules;
  cfg = cfm.dev.rust;
  homeDir = my.homedir;
  rustup_dir = "${homeDir}/.local/share/rustup";
  package = pkgs.rustup;
in {
  options.modules.dev.rust = {
    enable = mkEnableOption "Whether to dev rust";
    enSlsp = mkEnableOption "Whether to use system rust-lsp";
    version = mkStrOpt "stable";
    initScript = mkOpt' types.lines "" "init script";
  };
  config = mkIf cfg.enable {
    modules = {
      shell = {
        env = {
          RUSTUP_HOME = rustup_dir;
          CARGO_HOME = let
            cargoConfig = ''
              [source.crates-io]
              replace-with = 'ustc'
              [source.ustc]
              registry = "git://mirrors.ustc.edu.cn/crates.io-index"

              [install]
              root = "${homeDir}/.local"
              # [build]
              # target-dir = "${config.home.cacheDir}/cargo/target"
            '';
          in "${pkgs.runCommandLocal "cargo-home" {inherit cargoConfig;} ''
            mkdir -p $out
            ln -st $out "${config.home.cacheDir}"/cargo/{registry,git}
            ln -st $out "${config.home.configDir}"/cargo/credentials.toml
            echo -n "$cargoConfig" >$out/config.toml
          ''}";
        };
        aliases = {
          up_cargo = "cargo install-update -a";
          rs = "rustc";
          rsp = "rustup";
          ca = "cargo";
        };
        zsh.rcInit = ''
          zinit as="completion" for \
            OMZP::rust/_rustc
        '';
      };
      dev.rust.initScript =
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
          if [[ -f ${config.home.binDir}/rust-analyzer ]]; then
              echo "rust-analyzer alread installed."
          elif [ "$(${package}/bin/rustup component list | grep -i rust-analyzer )" != "" ]; then
               echo "start Install rust-analyzer"
              ${package}/bin/rustup component add rust-analyzer
              [[ -f "${config.home.binDir}/rust-analyzer" ]] || \
                ln -st ${config.home.binDir} $(${package}/bin/rustup which rust-analyzer)
          else
              echo "warn: Low version of rust"
              echo "warn: Please use cargo install or system command to install it"
          fi
        '';
    };
    home.packages = with pkgs; [
      package
      (mkIf cfg.enSlsp rust-analyzer)
      cargo-update
    ];
  };
}
