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
  cfm = config.modules;
  cfg = cfm.dev.rust;
  homeDir = my.homedir;
  rustup_dir = "${homeDir}/.local/share/rustup";
  package = pkgs.rustup;
in
{
  options.modules.dev.rust = {
    enable = mkEnableOption "Whether to dev rust";
    enSlsp = mkEnableOption "Whether to use system rust-lsp";
    version = mkStrOpt "stable";
  };
  config = mkIf cfg.enable {
    modules.shell = {
      env = {
        RUSTUP_HOME = rustup_dir;
        CARGO_HOME =
          let
            cargoConfig = ''
              [source.crates-io]
              replace-with = 'ustc'

              [source.ustc]
              registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

              [registries.ustc]
              index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

              [install]
              root = "${homeDir}/.local"
              # [build]
              # target-dir = "${config.home.cacheDir}/cargo/target"
            '';
          in
          "${pkgs.runCommandLocal "cargo-home" { inherit cargoConfig; } ''
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
    my.user.init.init-rust = ''
      mkdir ("${config.home.cacheDir}" | path join "cargo/registry")
      mkdir ("${config.home.cacheDir}" | path join "cargo/git")
      mkdir ("${config.home.configDir}" | path join "cargo")
      touch ("${config.home.configDir}" | path join "cargo/credentials.toml")
      let rust_version = "${cfg.version}"
      $env.RUSTUP_HOME = "${rustup_dir}"
      if (${package}/bin/rustup toolchain list | str contains $rust_version) {
        log debug "Rust alread installed."
      } else {
        ${package}/bin/rustup toolchain install $rust_version --component rust-src
        ${package}/bin/rustup default $rust_version
      }
    ''
    + optionalString (!cfg.enSlsp) ''
      if ("${config.home.binDir}" | path join "rust-analyzer" | path exists) {
        log debug "Rust-analyzer alread installed."
      } else if (${package}/bin/rustup component list | str contains "rust-analyzer") {
        log debug "Start install rust-analyzer"
        ${package}/bin/rustup component add rust-analyzer
        if (not ("${config.home.binDir}" | path join "rust-analyzer" | path exists)) {
          ln -st "${config.home.binDir}" (${package}/bin/rustup which rust-analyzer)
        }
      } else {
        log warning "Low version of rust!!!"
        log warning "Please use cargo install or system command to install rust-analyzer"
      }
    '';
    home.packages = with pkgs; [
      package
      (mkIf cfg.enSlsp rust-analyzer)
      cargo-update
    ];
  };
}
