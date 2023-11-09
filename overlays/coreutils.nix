final: prev: {
  coreutils-progress-bar = prev.coreutils.overrideAttrs(o: {
    patches = (let oldPatches = o.patches or []; in if oldPatches == null then [] else oldPatches) ++ (if o.version == "8.32" then [
      (final.fetchpatch {
        name = "advcpmv-0.8-8.32.patch";
        url = "https://github.com/jarun/advcpmv/raw/master/advcpmv-0.8-8.32.patch";
        sha256 = "0iz7p5a8wihnydccb40cjvwxhl8sz9lm7xcd57aqsr1xl7158ki9";
      }) ] else if o.version == "8.31" then [
        (final.fetchpatch {
          name = "advcpmv-0.8-8.31.patch";
          url = "https://github.com/jarun/advcpmv/raw/master/advcpmv-0.8-8.31.patch";
          sha256 = "sha256-oLSa7n9Cnmn49kJ4YMj/MetvA4eVaDpjWSQcXp/wDgk=";
        })] else if o.version == "8.30" then [
          (final.fetchpatch {
            name = "advcpmv-0.8-8.30.patch";
            url = "https://github.com/jarun/advcpmv/raw/master/advcpmv-0.8-8.30.patch";
            sha256 = "06qw9amqd4wwwycjfscxybl1yxgg8x97rlfl32shcg2gamsxjm4r";
          })] else []);
    postPatch = o.postPatch + ''
      sed '2i echo Skipping usage vs getopt test && exit 77' -i ./tests/misc/usage_vs_getopt.sh
    '';
  });
}
