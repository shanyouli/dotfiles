{ fetchurl, stdenv, lib, coreutils, unzip, jq, zip, writeScript, ... }:
let

  buildFirefoxXpiAddon = { name, url,sha256, fixedExtid ? null, ...}:
    stdenv.mkDerivation rec {
      inherit name;
      extid = if fixedExtid == null then "nixos@${name}" else fixedExtid;
      passthru = {
        inherit extid;
      };
      builder = writeScript "xpibuilder" ''
        source $stdenv/setup

        header "firefox addon $name into $out"

        UUID="${extid}"
        mkdir -p "$out/$UUID"
        unzip -q ${src} -d "$out/$UUID"
        NEW_MANIFEST=$(jq '. + {"applications": { "gecko": { "id": "${extid}" }}, "browser_specific_settings":{"gecko":{"id": "${extid}"}}}' "$out/$UUID/manifest.json")
        echo "$NEW_MANIFEST" > "$out/$UUID/manifest.json"
        cd "$out/$UUID"
        zip -r -q -FS "$out/$UUID.xpi" *
        rm -r "$out/$UUID"
      '';
      src = fetchurl { inherit url sha256; };
      nativeBuildInputs = [ coreutils unzip zip jq  ];
    };
  packages = import ./generated-firefox-addons.nix {
    inherit buildFirefoxXpiAddon fetchurl stdenv;
  };
in packages // { inherit buildFirefoxXpiAddon; }
