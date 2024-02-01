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
    echo-info "Use asdf initialization development ${plugin}"
    function asdf_${plugin}_init() {
      local exist_ver=""
      local all_ver=""
      local is_install_p=0
      exist_ver=$(mktemp)
      ${bin} list ${plugin} > "$exist_ver"
      ${concatStrings (map (v: ''
        is_install_p=0
        if grep ' ${v}\|*${v}$' "$exist_ver" >/dev/null 2>&1; then
          is_install_p=1
          echo-debug "${v} version has been installed."
        fi
        if [[ $is_install_p == 0 ]]; then
          if [[ $all_ver == "" ]]; then
            all_ver=$(mktemp)
            ${bin} list all ${plugin} > "$all_ver"
          fi
          if ! grep '^${v}$' "$all_ver" >/dev/null 2>&1; then
            echo-info "Install ${plugin} ${v} ..."
            asdf install ${plugin} ${v}
          else
            echo-error "${plugin} version ${v} not found!"
          fi
        fi
      '')
      versions)}
    }
    asdf_${plugin}_init
  '';
}
