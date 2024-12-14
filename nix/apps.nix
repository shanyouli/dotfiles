{inputs, ...}: {
  perSystem = {
    self',
    my,
    pkgs,
    ...
  }: {
    apps.update.program = let
      allInputs = builtins.attrNames inputs;
      filterFn = v: let
        filterList =
          if pkgs.stdenvNoCC.isDarwin
          then ["nixos-stable" "self"]
          else ["darwin" "darwin-stable" "self"];
      in
        builtins.filter (x: ! (builtins.elem x filterList)) v;
      stableInputs = filterFn allInputs;
      baseInputs = builtins.filter (x: !(builtins.elem x ["nixos-stable" "darwin" "darwin-stable" "self"])) allInputs;
    in
      my.writeNuScriptBin "update-flake" ''
        use std log
        log info $"The execution file path is ($env.FILE_PWD)/update-flake"
        # nix flake update inputs
        def main [--all(-a), --stable(-s)] {
          if $all {
            log info "update all flake inputs."
            ^nix flake update --commit-lock-file
            return 0
          }
          if $stable {
            log info $"(ansi blue_bold)>>>(ansi reset) update (ansi blue_bold)${pkgs.lib.concatStringsSep " " stableInputs}(ansi reset)"
            ^nix flake update ${pkgs.lib.concatStringsSep " " stableInputs} --commit-lock-file
          } else {
            log info $"(ansi blue_bold)>>>(ansi reset) update (ansi blue_bold)${pkgs.lib.concatStringsSep " " baseInputs}(ansi reset)"
            ^nix flake update ${pkgs.lib.concatStringsSep " " baseInputs} --commit-lock-file
          }
        }
      '';
    apps.checks = let
      drv = let
        bin = pkgs.writeShellScriptBin "drv-checkos" ''
          echo check ok
        '';
      in
        pkgs.runCommand "checks-combined" {
          checksss = builtins.attrValues self'.checks;
          buildInputs = [bin];
        } ''
          mkdir -p $out/bin
          cp ${bin} $out/bin/checks-combined
        '';
    in {
      type = "app";
      program = "${drv}/bin/drv-checkos";
    };
  };
}
