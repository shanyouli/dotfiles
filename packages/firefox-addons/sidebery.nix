{
  lib,
  source,
  buildNpmPackage,
}: let
  addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
in
  buildNpmPackage rec {
    inherit (source) pname version src;
    npmDepsHash = "sha256-5Wen+1ERDNBeVYkcBe7d8QVPrIMCsvCeOGUnQWNj7uw=";
    installPhase = ''
      npm run build.ext
      dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
      mkdir -p "$dst"
      cp -a dist/sidebery*.zip "$dst/${addonId}.xpi"
    '';

    meta = with lib; {
      description = "Firefox extension for managing tabs and bookmarks in sidebar";
      homepage = "https://github.com/mbnuqw/sidebery";
      changelog = "https://github.com/mbnuqw/sidebery/blob/${src.rev}/CHANGELOG.md";
      license = licenses.mit;
      maintainers = with maintainers; [lyeli];
      mainProgram = "sidebery";
      platforms = platforms.all;
    };
  }
