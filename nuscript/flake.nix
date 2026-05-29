{
  description = "m - Nushell Plugin Framework for Homebrew";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "m";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pkgs.nushell ];

          installPhase = ''
            mkdir -p $out/share/m
            cp -r . $out/share/m

            mkdir -p $out/bin
            makeWrapper ${pkgs.nushell}/bin/nu $out/bin/m \
              --add-flags "$out/share/m/mod.nu"
          '';

          meta = with pkgs.lib; {
            description = "Nushell plugin framework for Homebrew and Git";
            homepage = "https://github.com/lyeli/m";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };

        devShells.default = pkgs.mkShell { buildInputs = [ pkgs.nushell ]; };
      }
    );
}
