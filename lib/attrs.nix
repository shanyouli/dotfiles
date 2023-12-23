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

  asdfInPlugins = bin: plugin: versions: ''
    version_exist=( $(${bin} list ${plugin}) )
    all_versions=$(${bin} list all ${plugin})
    ${concatStrings (map (v: ''
        is_install_p=1
        for i in ''${version_exist[@]}; do
          if [[ $i == "${v}" ]] || [[ $i == "*${v}" ]]; then
            is_install_p=0
            break
          fi
        done
        if [[ $is_install_p == 1 ]]; then
          for i in ''${all_versions[@]}; do
            if [[ $i == "${v}" ]]; then
              is_install_p=0
              ${bin} install ${plugin} ${v}
              break
            fi
          done
        fi
        if [[ $is_install_p == 1 ]]; then
          echo "Warning: ${plugin} No ${v} version!!!"
        fi
      '')
      versions)}
  '';
}
