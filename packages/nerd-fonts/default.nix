{ fetchurl, lib, unzip, stdenv }:
# If you want to install WindowsFonts font, use the following expressions
# fonts = with pkgs; [
#   (nerd-fonts.fantasque-sans-mono.overrideAttrs (old: {
#     enableWindowsFonts = true;
#   }))
# ];
let
  version = "2.1.0";
  enableWindowsFonts = false;
  buildNerdFont = { pname, sha256, ...}:
    stdenv.mkDerivation {
      inherit version enableWindowsFonts;
      name = "${pname}-${version}";
      src = fetchurl {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${pname}.zip";
        inherit sha256;
      };
      nativeBuildInputs = [ unzip ];
      sourceRoot = ".";
      buildPhase = ''
        echo "Install NerdFont-${pname}-${version}"
      '';
      installPhase = ''
        find -name \*.ttf -exec mkdir -p $out/share/fonts/truetype \; -exec mv {} $out/share/fonts/truetype \;
        ${lib.optionalString (! enableWindowsFonts) ''
          rm -rfv $out/share/fonts/truetype/*Windows\ Compatible.*
        ''}
      '';
      meta = with stdenv.lib; {
        description = "Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts";
        longDescription = ''
          Nerd Fonts is a project that attempts to patch as many developer targeted
          and/or used fonts as possible. The patch is to specifically add a high
          number of additional glyphs from popular 'iconic fonts' such as Font
          Awesome, Devicons, Octicons, and others.
        '';
        homepage = "https://nerdfonts.com/";
        license = licenses.mit;
        maintainers = with maintainers; [ doronbehar ];
        hydraPlatforms = []; # 'Output limit exceeded' on Hydra
      };
    };
  packages = import ./all-nerd-fonts.nix {
    inherit buildNerdFont;
  };
in packages // { inherit buildNerdFont ; }
