{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "IINA";
  version = "2.9.9";
  src = fetchurl {
    url = "https://github.com/Yidadaa/ChatGPT-Next-Web/releases/download/v${version}/ChatGPT.Next.Web_${version}_x64.dmg";
    sha256 = "09kkl97kk13cmfkizjcnf1ylggs25s77ss35z3y4qq70v5kbl6r8";
  };
  appMeta = {
    description = "ChatGpt Next Web";
    homepage = "https://github.com/Yidadaa/ChatGPT-Next-Web";
  };
}
