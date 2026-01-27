((nil .
      ((eglot-workspace-configuration . (:nixd (:options (:nixos (:expr "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.test@x86_64-linux.options")
                                                                 :nixpkgs (:expr "import <nixpkgs> {}")
                                                                 :home-manager (:expr "(builtins.getFlake (builtins.toString ./.)).legacyPackages.aarch64-darwin.homeConfigurations.test.options")
                                                                 :darwin (:expr "(builtins.getFlake (builtins.toString ./.)).darwinConfigurations.test@aarch64-darwin.options"))))))))
