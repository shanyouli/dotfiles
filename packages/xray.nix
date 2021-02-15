{ symlinkJoin, xray-core, xray-asset, makeWrapper }:

symlinkJoin {
  name = "xray-${xray-core.version}";
  paths = [ xray-core ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/xray \
      --set XRAY_LOCATION_ASSET "${xray-asset}/share/xray-asset"
  '';
}
