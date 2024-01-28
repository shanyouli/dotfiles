{
  mkDarwinApp,
  source,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "ChatGPT";
  meta = {
    description = "ChatGPT Desktop Application (Mac, Windows and Linux) ";
    homepage = "https://app.nofwl.com/chatgpt";
  };
}
