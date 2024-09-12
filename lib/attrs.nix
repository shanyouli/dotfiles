{lib, ...}:
with builtins;
with lib; rec {
  # attrsToList
  attrsToList = attrs:
    mapAttrsToList (name: value: {inherit name value;}) attrs;

  # mapFilterAttrs ::
  #   (name -> value -> bool)
  #   (name -> value -> { name = any; value = any; })
  #   attrs
  mapFilterAttrs = pred: f: attrs: filterAttrs pred (mapAttrs' f attrs);

  # Generate an attribute set by mapping a function over a list of values.
  genAttrs' = values: f: listToAttrs (map f values);

  # anyAttrs :: (name -> value -> bool) attrs
  anyAttrs = pred: attrs:
    any (attr: pred attr.name attr.value) (attrsToList attrs);

  # countAttrs :: (name -> value -> bool) attrs
  countAttrs = pred: attrs:
    count (attr: pred attr.name attr.value) (attrsToList attrs);

  sudoNotPass = username: cmd: ''
    ${username} ALL = (root) NOPASSWD: sha256:${builtins.hashFile "sha256" "${cmd}"} ${cmd}
  '';

  strToLists = sep: str:
    filter (s: isString s && s != "") (split sep str);

  strDeletePrefix = prefix: str: let
    lenPrefix = stringLength prefix;
  in (
    if (substring 0 lenPrefix str == prefix)
    then substring (stringLength prefix) (stringLength str) str
    else ""
  );
  optionalNull = cond: result:
    if cond
    then result
    else null;

  relativeToRoot = lib.path.append ../.;
}
