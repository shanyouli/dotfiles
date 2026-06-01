_: {
  perSystem =
    { self', pkgs, ... }:
    {
      apps.checks =
        let
          drv =
            let
              bin = pkgs.writeShellScriptBin "drv-checkos" ''
                echo check ok
              '';
            in
            pkgs.runCommand "checks-combined"
              {
                checksss = builtins.attrValues self'.checks;
                buildInputs = [ bin ];
              }
              ''
                mkdir -p $out/bin
                cp ${bin} $out/bin/checks-combined
              '';
        in
        {
          type = "app";
          program = "${drv}/bin/drv-checkos";
        };
    };
}
