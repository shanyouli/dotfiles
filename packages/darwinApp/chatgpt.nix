{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "ChatGPT";
  version = "1.1.0";
  src = fetchurl {
    url = "https://github.com/lencx/ChatGPT/releases/download/v${version}/ChatGPT_${version}_macos_aarch64.dmg";
    sha256 = "1xh0907j33l7kk3y40q8ch48vjwanfskic6bfia7346rb89vlw7q";
  };
  appMeta = {
    description = "ChatGPT Desktop Application (Mac, Windows and Linux) ";
    homepage = "https://app.nofwl.com/chatgpt";
  };
}
