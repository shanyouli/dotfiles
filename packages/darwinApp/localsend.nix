{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "LocalSend";
  version = "1.11.1";
  src = fetchurl {
    url = "https://github.com/localsend/localsend/releases/download/v${version}/LocalSend-${version}.dmg";
    sha256 = "020j5ii45c19gkp49rbvil8zgxf4h8zv6cvva8k1011q8b9nhb0a";
  };
  appMeta = {
    description = "Share files to nearby devices. Free, open source, cross-platform";
    homepage = "https://localsend.org/#/";
  };
}
