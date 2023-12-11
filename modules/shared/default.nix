{
  lib,
  config,
  ...
}:
with lib;
with lib.my; {
  config.my.modules = mkMerge [
    {
    }
  ];
}
