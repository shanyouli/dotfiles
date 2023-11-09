{ lib, pkgs, ... }:

with builtins;
with lib;
{
  toCSSFile = file:
    let fileName = removeSuffix ".scss" (baseNameOf file);
        compiledStyles =
          pkgs.runCommand "compileScssFile"
            { buildInputs = [ pkgs.sass ]; } ''
              mkdir "$out"
              scss --sourcemap=none \
                   --no-cache \
                   --style compressed \
                   --default-encoding utf-8 \
                   "${file}" \
                   >>"$out/${fileName}.css"
            '';
    in "${compiledStyles}/${fileName}.css";

  toFilteredImage = imageFile: options:
    let result = "result.png";
        filteredImage =
          pkgs.runCommand "filterWallpaper"
            { buildInputs = [ pkgs.imagemagick ]; } ''
              mkdir "$out"
              convert ${options} ${imageFile} $out/${result}
            '';
    in "${filteredImage}/${result}";
  text.substitution = file: old: new:
    let fileName = builtins.baseNameOf file;
        subCommand = pkgs.runCommand "substitutionTxt" {
          buildInputs = [ pkgs.gnused pkgs.coreutils ];
        } ''
          mkdir "$out"
          install ${file} $out/${fileName}
          sed -i "s|${old}|${new}|g" $out/${fileName}
        '';
    in "${subCommand}/${fileName}";
  homePkgFun = home: pkg: pkgs.symlinkJoin {
    name = "my-" + (if (pkg ? pname)
                    then pkg.pname + "-" + pkg.version
                    else pkg.name );
    paths = [ pkg ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for i in $out/bin/* ; do
        wrapProgram $i --set HOME "${home}"
      done
    '';
  };
}
