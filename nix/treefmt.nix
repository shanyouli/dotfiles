{ inputs, ... }: {
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = { config, ... }: {
    treefmt = {
      projectRootFile = "flake.nix";
      settings.global.excludes = [
        "hosts/**/hardware-*.nix"
        "*.gpg"
        "*.lock"
        "orbstack.nix"
      ];

      programs = {
        # nix format
        statix.enable = true; # nix static analysis
        deadnix = {
          no-lambda-arg = true;
          enable = true;
        };
        nixfmt = {
          enable = true;
          strict = true;
          width = 100;
        };
        # python
        ruff-format.enable = true;
        ruff-check.enable = true;
        # lua
        stylua.enable = true;

        # bash
        shellcheck.enable = true;
        shfmt = {
          enable = true;
          indent_size = 4;
        };

        # JS/TS/JSON/CSS
        # oxfmt 只做格式化；oxlint（treefmt-nix 无对应 program）不进 treefmt。
        # oxfmt 默认 includes 还包含 md/yaml/vue 等，这里收窄到原本 biome 覆盖的范围。
        oxfmt = {
          enable = true;
          includes = [
            "*.js"
            "*.mjs"
            "*.cjs"
            "*.jsx"
            "*.ts"
            "*.mts"
            "*.cts"
            "*.tsx"
            "*.json"
            "*.jsonc"
            "*.css"
          ];
        };
        # justfile
        just.enable = true;
      };
    };
    formatter = config.treefmt.build.wrapper;
  };
}
