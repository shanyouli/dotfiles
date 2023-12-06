{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "chatgpt-next-web";
  version = "2.9.12";
  src = fetchurl {
    url = "https://github.com/Yidadaa/ChatGPT-Next-Web/releases/download/v${version}/ChatGPT.Next.Web_${version}_x64.dmg";
    sha256 = "sha256-WRr+J3LVLWpmuMhCC+G5rf3S0Z0z5uaLnsK6P7W1/rg=";
  };
  appMeta = {
    description = "ChatGpt Next Web";
    homepage = "https://github.com/Yidadaa/ChatGPT-Next-Web";
  };
}
