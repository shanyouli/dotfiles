let version = "0.15.1";
in
final: prev: {
  sarasa-gothic = prev.sarasa-gothic.overrideAttrs (oldAttrs: rec {
    inherit version;
    name = "sarasa-gothic-${version}";
    url = "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${version}/sarasa-gothic-ttc-${version}.7z";
    sha256 = "sha256-crnuPsbHDGeEvB8YAuJtNMkephs89KabXQo7Av1ez54=";
  });
}
