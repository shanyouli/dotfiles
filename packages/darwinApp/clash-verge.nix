{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  pname = "clash-verge";
  version = "1.3.8";
  src = fetchurl {
    url = "https://github.com/zzzgydi/clash-verge/releases/download/v${version}/Clash.Verge_${version}_aarch64.dmg";
    sha256 = "sha256-/YNwMjppWogo0adIfJ50IAzja1GzJElb+6IUmMb8jEg=";
  };
  meta = {
    description = "A Clash GUI based on tauri. Supports Windows, macOS and Linux. ";
    homepage = "https://github.com/zzzgydi/clash-verge";
  };
}
