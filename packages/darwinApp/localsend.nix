{
  mkDarwinApp,
  source,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "LocalSend";
  meta = {
    description = "Share files to nearby devices. Free, open source, cross-platform";
    homepage = "https://localsend.org/#/";
  };
}
