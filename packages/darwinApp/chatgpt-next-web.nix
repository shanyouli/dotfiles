{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "NextChat";
  version = "2.10.1";
  src = fetchurl {
    url = "https://github.com/ChatGPTNextWeb/ChatGPT-Next-Web/releases/download/v${version}/NextChat_${version}_x64.dmg";
    sha256 = "1706qbgq79r29y18nc962vvilk3yx2cy101xd6sziic3wc1nfdc3";
  };
  appMeta = {
    description = "ChatGpt Next Web";
    homepage = "https://github.com/Yidadaa/ChatGPT-Next-Web";
  };
}
