{
  lib,
  runCommand,
  installShellFiles,
  source,
}:
runCommand "yabai-zsh-completions" {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;

  nativeBuildInputs = [installShellFiles];

  meta = with lib; {
    homepage = "https://github.com/Amar1729/yabai-zsh-completions";
    description = "zsh completions for yabai, the tiling window manager";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
} ''
  installShellCompletion --zsh $src/src/_yabai
''
