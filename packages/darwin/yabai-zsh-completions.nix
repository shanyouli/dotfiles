{
  lib,
  runCommand,
  fetchFromGitHub,
  installShellFiles,
}:
runCommand "yabai-zsh-completions" {
  pname = "yabai-zsh-completions";
  version = "2023-12-01";

  src = fetchFromGitHub {
    owner = "Amar1729";
    repo = "yabai-zsh-completions";
    rev = "6e38681a002e13bdcd43f461f73c53b7c11fd4e5";
    sha256 = "sha256-II00E32Pnt7PO+PcTtWp4NzSUDhQJTgAPw9HdlItbhQ=";
  };

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
