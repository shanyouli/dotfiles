{lib, ...}: let
  inherit (lib) mkOption types mkOptionType isFunction concatMap getValues foldl' mergeAttrs;
in rec {
  mkOpt = type: default: mkOption {inherit type default;};

  mkOpt' = type: default: description:
    mkOption {inherit type default description;};

  mkBoolOpt = default:
    mkOption {
      inherit default;
      type = types.bool;
      example = true;
    };
  mkStrOpt = default:
    mkOption {
      inherit default;
      type = with types; nullOr str;
      example = null;
    };
  mkNumOpt = default:
    mkOption {
      inherit default;
      type = types.number;
      example = 10;
    };
  mkPkgReadOpt = description:
    mkOption {
      inherit description;
      type = types.package;
      visible = false;
      readOnly = true;
    };

  selectorFunction = mkOptionType {
    name = "selectorFunction";
    description =
      "Function that takes an attribute set and returns a list"
      + " containing a selection of the values of the input set";
    check = isFunction;
    merge = _loc: defs: as: concatMap (select: select as) (getValues defs);
  };
  overlayFunction = mkOptionType {
    name = "overlayFunction";
    description =
      "An overlay function, takes self and super and returns"
      + " an attribute set overriding the desired attributes.";
    check = isFunction;
    merge = _loc: defs: self: super:
      foldl' (res: def: mergeAttrs res (def.value self super)) {} defs;
  };
}
