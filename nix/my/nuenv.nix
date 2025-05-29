{ lib, pkgs, ... }:
let
  makeBinPathArray =
    packages:
    let
      binOutputs = builtins.filter (x: x != null) (map (pkg: lib.getOutput "bin" pkg) packages);
    in
    map (output: output + "/bin") binOutputs;
in
rec {
  toNu = v: "(\"${lib.escape [ "\"" "\\" ] (builtins.toJSON v)}\" | from json)";
  writeNuScript' =
    {
      /*
        The name of the script to write
        Type: String
      */
      name,
      /*
        The shell script's text, not including a shebang.
        Type: String
      */
      text,
      /*
        The using nushell package.
        Type: package.
      */
      nushell ? pkgs.nushell,
      /*
        The 'checkPhase' to run. Defaults to 'nu-check'.
        THe script path will be given as `$target' in the `checkPhase`.
        Type: String
      */
      checkPhase ? null,
      /*
        By default, the store path itself will be a file containing the text contents.
        Type: String
      */
      destination ? "",
    }:
    pkgs.writeTextFile {
      inherit destination;
      name = if destination == "" then "${name}.nu" else name;
      executable = true;
      text = ''
        #!${nushell}/bin/nu
        ${text}
      '';
      checkPhase =
        if checkPhase == null then
          ''
            runHook preCheck
            ${nushell}/bin/nu --commands "nu-check '$target'"
            runHook postCheck
          ''
        else
          checkPhase;
    };
  writeNuScript = name: text: writeNuScript' { inherit name text; };

  writeNuScriptBin =
    name: text:
    writeNuScript' {
      inherit name text;
      destination = "/bin/${name}";
    };
  # see @https://github.com/hallettj/nuenv/blob/writeShellApplication/lib/writeShellApplication.nix
  writeNuApplication =
    {
      /*
        The name of the script to write.

        Type: String
      */
      name,
      /*
        The shell script's text, not including a shebang.

        Type: String
      */
      text,
      /*
        Inputs to add to the shell script's `$PATH` at runtime.

        Type: [String|Derivation]
      */
      runtimeInputs ? [ ],
      /*
        Extra environment variables to set at runtime.

        Type: AttrSet
      */
      runtimeEnv ? null,
      /*
        `stdenv.mkDerivation`'s `meta` argument.

        Type: AttrSet
      */
      meta ? { },
      /*
        The `checkPhase` to run. Defaults to `shellcheck` on supported
        platforms and `bash -n`.

        The script path will be given as `$target` in the `checkPhase`.

        Type: String
      */
      checkPhase ? null,
      /*
        Extra arguments to pass to `stdenv.mkDerivation`.

        :::{.caution}
        Certain derivation attributes are used internally,
        overriding those could cause problems.
        :::

        Type: AttrSet
      */
      derivationArgs ? { },
      nushell ? pkgs.nushell,
      /*
        Extra arguments to pass into nushell invoker
        Defaults to allowing stdin with "--stdin".
        See all arguments with `nu --help`

        Type: [String]
      */
      nushellArgs ? [ "--stdin" ],
    }:
    pkgs.writeTextFile {
      inherit name meta derivationArgs;
      executable = true;
      destination = "/bin/${name}";
      allowSubstitutes = true;
      preferLocalBuild = false;
      tet =
        ''
          #!/usr/bin/env -S ${lib.concatStringsSep " " ([ (lib.getExe nushell) ] ++ nushellArgs)}
        ''
        + lib.optionalString (runtimeEnv != null) ''

          load-env ${toNu runtimeEnv}
        ''
        + lib.optionalString (runtimeInputs != [ ]) ''

          $env.PATH = ${toNu (makeBinPathArray runtimeInputs)} ++ $env.PATH
        ''
        + ''
          ${text}
        '';
      checkPhase =
        if checkPhase == null then
          ''
            runHook preCheck
            ${nushell}/bin/nu --commands "nu-check '$target'"
            runHook postCheck
          ''
        else
          checkPhase;
    };
}
