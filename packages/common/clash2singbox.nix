{
  lib,
  buildGoModule,
  source,
}:
buildGoModule rec {
  inherit (source) pname version src vendorHash;

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "将 clash.meta 格式的配置文件或链接转换为 sing-box 格式";
    homepage = "https://github.com/xmdhs/clash2singbox";
    license = licenses.mit;
    maintainers = with maintainers; [lyeli];
    mainProgram = "clash2singbox";
  };
}
