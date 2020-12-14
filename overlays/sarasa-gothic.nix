let version = "0.16";
in
final: prev: {
  sarasa-gothic = prev.sarasa-gothic.overrideAttrs (oldAttrs: rec {
    inherit version;
    name = "sarasa-gothic-${version}";
    url = "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${version}/sarasa-gothic-ttc-${version}.7z";
    sha256 = "";
    # sha256 = "1h8dlxdls3na8n71jhqvvb3vr7ri1myj7d346p4nvib31pqyl3an";
  });
}
