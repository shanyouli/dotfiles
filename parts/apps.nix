{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    apps.update.program = let
      allInputs = builtins.attrNames inputs;
      filterFn = v: let
        filterList =
          if pkgs.stdenvNoCC.isDarwin
          then ["nixos" "self"]
          else ["darwin" "darwin-stable" "self"];
      in
        builtins.filter (x: ! (builtins.elem x filterList)) v;
      stableInputs = filterFn allInputs;
      baseInputs = builtins.filter (x: !(builtins.elem x ["nixos" "darwin" "darwin-stable" "self"])) allInputs;
    in
      pkgs.writeScriptBin "update-flake" ''
        #!${pkgs.lib.getExe pkgs.nushell}
        use std log
        log info $"The execution file path is ($env.FILE_PWD)/update-flake"
        # nix flake update inputs
        def main [--all(-a), --stable(-s)] {
          if $all {
            log info "update all flake inputs."
            ^nix flake lock
            return 0
          }
          if $stable {
            log info $"(ansi blue_bold)>>>(ansi reset) update (ansi blue_bold)${pkgs.lib.concatStringsSep " " stableInputs}(ansi reset)"
            ^nix flake lock ${pkgs.lib.concatMapStringsSep " " (x: "--update-input ${x}") stableInputs}
          } else {
            log info $"(ansi blue_bold)>>>(ansi reset) update (ansi blue_bold)${pkgs.lib.concatStringsSep " " baseInputs}(ansi reset)"
            ^nix flake lock ${pkgs.lib.concatMapStringsSep " " (x: "--update-input ${x}") baseInputs}
          }
        }
      '';
  };
}
