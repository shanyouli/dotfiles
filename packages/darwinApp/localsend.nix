{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "LocalSend";
  version = "1.12.0";
  src = fetchurl {
    url = "https://github.com/localsend/localsend/releases/download/v${version}/LocalSend-${version}.dmg";
    sha256 = "sha256-XKYc3lA7x0Tf1Mf3o7D2RYwYDRDVHoSb/lj9PhKzV5U=";
  };
  appMeta = {
    description = "Share files to nearby devices. Free, open source, cross-platform";
    homepage = "https://localsend.org/#/";
  };
}
