[
  (self: super: with super; {
    fira-sans = (callPackage ./fira-sans.nix {});
    nerd = {
      fantasquesansmono = (callPackage ./fantasquesansmono.nix {});
      mononoki          = (callPackage ./mononoki.nix {});
    };
    sarasa-gothic = (callPackage ./sarasa-gothic.nix {});
    # nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    #   inherit super;
    # };
  })
]
