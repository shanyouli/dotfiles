{config, ...}: {
  modules.xdg.enable = true;
  environment = {
    sessionVariables = config.modules.xdg.value;
    extraInit = ''
      export XAUTHORITY=/tmp/Xauthority
      [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
    '';
  };
}
