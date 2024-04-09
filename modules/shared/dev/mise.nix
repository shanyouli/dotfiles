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
  cfg = cfm.dev.mise;
  cfbin = "${cfg.package}/bin/mise";
in {
  options.modules.dev.mise = with types; {
    enable = mkEnableOption "Whether to use mise";
    plugins = mkOption {
      description = "mise install plugins";
      type = attrsOf (oneOf [(nullOr bool) (listOf str)]);
      default = {};
    };
    package = mkPkgOpt pkgs.unstable.mise "mise package";

    text = mkOpt' lines "" "init mise script";
    prevInit = mkOpt' lines "" "prev mise env";
    extInit = mkOpt' lines "" "extra mise Init";
  };
  config = mkIf cfg.enable {
    user.packages = [cfg.package];
    modules.shell.env.MISE_CACHE_DIR = "${config.home.cacheDir}/mise";
    modules.shell.rcInit = ''_cache -v ${cfg.package.version} mise activate zsh'';
    modules.dev.mise.text = let
      mise_in_plugin_fn = v: ''${cfbin} p add ${v} -y'';
      mise_plugin_ver_fn = p: vers:
        concatStrings (map (v: ''
            echo-info "Use ${p} ${v} ..."
            ${cfbin} install ${p}@${v}
          '')
          vers);
      text = concatStringsSep "\n" (mapAttrsToList (n: v: (let
          ver = lib.optionalString (v != true) ''${mise_plugin_ver_fn n v}'';
          pin =
            lib.optionalString (! elem n ["python" "bun" "deno" "erlang" "go" "java" "ruby" "rust" "node"])
            ''${mise_in_plugin_fn n}'';
        in ''
          echo-info "Using mise to manage versions of ${n}"
          ${pin}
          ${ver}
        ''))
        (lib.filterAttrs (k: v: !(builtins.elem v [null false])) cfg.plugins));
    in ''
      ${cfg.prevInit}
      export MISE_CACHE_DIR="${config.home.cacheDir}/mise"
      ${text}
      ${cfg.extInit}
    '';
  };
}
