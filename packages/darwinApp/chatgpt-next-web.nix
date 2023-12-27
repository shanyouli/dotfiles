{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "chatgpt-next-web";
  version = "2.9.13";
  src = fetchurl {
    url = "https://github.com/Yidadaa/ChatGPT-Next-Web/releases/download/v${version}/ChatGPT.Next.Web_${version}_x64.dmg";
    sha256 = "09qpd0bq4x1vzm2b4pgjk7srj9rxdba6l027wkyp3kikd21h31h1";
  };
  appMeta = {
    description = "ChatGpt Next Web";
    homepage = "https://github.com/Yidadaa/ChatGPT-Next-Web";
  };
}
