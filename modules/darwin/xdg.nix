{config, ...}: {
  modules.xdg.enable = true;
  environment.variables = config.modules.xdg.value;
}
