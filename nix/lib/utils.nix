{ lib, ... }:
with lib;
with builtins;
rec {
  isDarwin = system: builtins.elem system lib.platforms.darwin;

  relativeToRoot = lib.path.append ../../.;

  strToLists = sep: str: filter (s: isString s && s != "") (split sep str);

  strDeletePrefix =
    prefix: str:
    let
      lenPrefix = stringLength prefix;
    in
    if (substring 0 lenPrefix str == prefix) then
      substring (stringLength prefix) (stringLength str) str
    else
      "";
  optionalNull = cond: result: if cond then result else null;
}
