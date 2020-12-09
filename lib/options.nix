{ lib, ... }:

let
  inherit (lib) mkOption types;
in
rec {
  mkOpt  = type: default:
    mkOption { inherit type default; };

  mkOpt' = type: default: description:
    mkOption { inherit type default description; };

  mkBoolOpt = default: mkOption {
    inherit default;
    type = types.bool;
    example = true;
  };
  mkStrOpt = default: mkOption {
    inherit default;
    type = with types; nullOr str;
    example = null;
  };
  mkPkgReadOpt = description: mkOption {
    inherit description;
    type = types.package;
    visible = false;
    readOnly = true;
  };
}
