{ lib, attrs, ... }:
let
  inherit (builtins)
    attrValues
    readDir
    pathExists
    concatLists
    ;
  inherit (lib)
    id
    mapAttrsToList
    filterAttrs
    hasPrefix
    hasSuffix
    nameValuePair
    removeSuffix
    mapAttrs'
    pathIsDirectory
    ;
  inherit (attrs) mapFilterAttrs';
in
rec {
  loadFile =
    fn: path:
    let
      filePath = toString path;
    in
    if pathIsDirectory filePath then
      fn (filePath + "/default.nix")
    else if pathExists (filePath + ".nix") then
      fn (filePath + ".nix")
    else
      throw "unknown path ${path}";

  mapModule =
    dir: fn:
    {
      namefn ? (n: removeSuffix ".nix" n),
      ...
    }:
    mapAttrs'
      (name: _type: {
        name = namefn name;
        value = fn (dir + "/${name}");
      })
      (
        filterAttrs (
          name: type:
          (type == "directory" && pathExists "${toString dir}/${name}/default.nix")
          || (type == "regular" && hasSuffix ".nix" name && name != "default.nix" && !(hasPrefix "_" name))
        ) (readDir dir)
      );

  mapModules =
    dir: fn:
    mapFilterAttrs' (
      n: v:
      let
        path = "${toString dir}/${n}";
      in
      if v == "directory" && pathExists "${path}/default.nix" then
        nameValuePair n (fn path)
      else if v == "regular" && n != "default.nix" && hasSuffix ".nix" n then
        nameValuePair (removeSuffix ".nix" n) (fn path)
      else
        nameValuePair "" null
    ) (n: v: v != null && !(hasPrefix "_" n)) (readDir dir);

  mapModules' = dir: fn: attrValues (mapModules dir fn);

  mapModulesRec =
    dir: fn:
    mapFilterAttrs' (
      n: v:
      let
        path = "${toString dir}/${n}";
      in
      if v == "directory" then
        nameValuePair n (mapModulesRec path fn)
      else if v == "regular" && n != "default.nix" && hasSuffix ".nix" n then
        nameValuePair (removeSuffix ".nix" n) (fn path)
      else
        nameValuePair "" null
    ) (n: v: v != null && !(hasPrefix "_" n)) (readDir dir);

  mapModulesRec' =
    dir: fn:
    let
      dirs = mapAttrsToList (k: _: "${dir}/${k}") (
        filterAttrs (n: v: v == "directory" && !(hasPrefix "_" n)) (readDir dir)
      );
      files = attrValues (mapModules dir id);
      paths = files ++ concatLists (map (d: mapModulesRec' d id) dirs);
    in
    map fn paths;
}
