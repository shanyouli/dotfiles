{
  mkDarwinApp,
  source,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "NextChat";
  meta = {
    description = "ChatGpt Next Web";
    homepage = "https://github.com/Yidadaa/ChatGPT-Next-Web";
  };
}
