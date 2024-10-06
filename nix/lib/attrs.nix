{lib, ...}:
with builtins;
with lib; rec {
  # attrsToList: attrs -> attrs
  # eg: { a = 1; b = 2; } ==> [{name = a; value = 1} {name = b; value = 2; }]
  attrsToList = attrs:
    mapAttrsToList (name: value: {inherit name value;}) attrs;

  # mapFilterAttrs ::
  #   (name -> value -> bool)
  #   (name -> value -> { name = any; value = any; })
  #   attrs
  #   -> attrs
  mapFilterAttrs = f: pred: attrs: filterAttrs pred (mapAttrs f attrs);
  mapFilterAttrs' = f: pred: attrs: filterAttrs pred (mapAttrs' f attrs);
  # mapFilterAttrs = pred: f: attrs: filterAttrs pred (mapAttrs' f attrs);

  # filterMapAttrs ::
  #   (name -> value -> {name = any; value = any; })
  #   (name -> value -> bool)
  #   attrs
  #   -> atrs
  filterMapAttrs = pred: f: attrs: (mapAttrs f (filterAttrs pred attrs));
  filterMapAttrs' = pred: f: attrs: (mapAttrs' f (filterAttrs pred attrs));

  # Generate an attribute set by mapping a function over a list of values.
  # genAttrs' :: list -> ((any -> any) -> attrs) -> attrs
  genAttrs' = values: f: listToAttrs (map f values);

  # anyAttrs :: (name -> value -> bool) attrs
  anyAttrs = pred: attrs:
    any (attr: pred attr.name attr.value) (attrsToList attrs);

  # countAttrs :: (name -> value -> bool) attrs
  countAttrs = pred: attrs:
    count (attr: pred attr.name attr.value) (attrsToList attrs);

  # Unlink //, this will deeply merge attrsets (left > right).
  # mergeAttrs' :: listOf attrs -> attrs
  mergeAttrs' = attrList: let
    f = attrPath:
      zipAttrsWith (
        n: values:
          if (tail values) == []
          then head values
          else if all isList values
          then unique (concatLists values)
          else if all isAttrs values
          then f (attrPath ++ [n]) values
          else last values
      );
  in
    f [] attrList;
}
