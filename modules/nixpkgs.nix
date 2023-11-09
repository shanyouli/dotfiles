{ inputs, config, lib, pkgs, ... }: {
  nix = {
    settings = {
      trusted-users = [ "${config.my.username}" "root" "@admin" "@wheel" ];
    };
    # envVars = {
    #   https_proxy = "http://127.0.0.1:7890";
    #   http_proxy = "http://127.0.0.1:7890";
    #   all_proxy = "http://127.0.0.1:7890";

    # };
  };
}
