{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfp = cfm.dev;
  cfg = cfp.manager;
  cfbin = "${cfg.package}/bin/mise";
  miseCacheDir = "${config.home.cacheDir}/mise";

  # nu 双引号字符串：不含 $ 插值，只需排除双引号 / 反斜杠 / 换行即可安全内联
  nuValue =
    kind: value:
    if hasInfix "\"" value || hasInfix "\\" value || hasInfix "\n" value then
      throw "modules.dev.manager: ${kind} 含引号、反斜杠或换行，拒绝生成初始化脚本: ${value}"
    else
      "\"${value}\"";

  # setting 键等标识符仍用严格字符集，避免拼出非法的 mise 键
  nuStr =
    kind: value:
    if builtins.match "[A-Za-z0-9_.:+/@-]+" value != null then
      "\"${value}\""
    else
      throw "modules.dev.manager: ${kind} 含不支持的字符，拒绝生成初始化脚本: ${value}";

  # 校验过的工具名（字符集不含引号与花括号，可直接内插进 nu 字符串）
  validateName =
    name:
    if builtins.match "[A-Za-z0-9_.:+/@-]+" name != null then
      name
    else
      throw "modules.dev.manager: 工具名含不支持的字符，拒绝生成初始化脚本: ${name}";

  # 生成 mise 的 dotted key：特殊字符（如 npm: / cargo:）需按 TOML 规则加引号
  toolKey =
    name:
    if builtins.match "[A-Za-z0-9_-]+" (validateName name) != null then
      "tools.${name}"
    else
      "tools.\"${name}\"";

  # 工具名已校验，含引号时用 nu 单引号字符串包裹即可，无需转义
  nuKey = key: if hasInfix "\"" key then "'${key}'" else "\"${key}\"";

  # plugins 的值支持：版本字符串、版本列表（取第一项）、bool/null（仅声明，不写版本）
  # 若 global 中显式指定了默认版本，则优先使用它。
  toolVersion =
    name: value:
    let
      defaultVersion = cfg.global.${name} or "";
    in
    if defaultVersion != "" then
      defaultVersion
    else if builtins.isString value then
      value
    else if builtins.isList value then
      let
        vers = filter builtins.isString value;
      in
      if vers == [ ] then "" else builtins.head vers
    else
      "";

  tools = filterAttrs (
    _: v:
    !(elem v [
      null
      false
    ])
  ) cfp.lang;

  # 幂等写入工具：仅在配置缺失或值为「单行纯字符串」且不同时写入；
  # 值是 table（带 tool 选项）或数组（多版本声明）时保留用户配置，不做覆盖。
  helperDefs = ''
    def mise-nix-set-setting [key: string, value: string] {
      # 已是目标值就不写，避免每次激活重写配置文件；
      # 只读全局配置文件，避免受项目配置 / 环境变量影响
      let cur = (do -i { ^${cfbin} config get --global $"settings.($key)" } | complete)
      if ($cur.exit_code == 0) and (($cur.stdout | str trim) == $value) {
        return
      }
      let res = (do -i { ^${cfbin} settings set $key $value } | complete)
      if $res.exit_code != 0 {
        log warning $"mise: 设置 ($key) = ($value) 失败: ($res.stderr | str trim | str replace -a (char nl) ' ')"
      }
    }

    def mise-nix-set-tool [key: string, want: string] {
      let cur = (do -i { ^${cfbin} config get --global $key } | complete)
      let val = ($cur.stdout | str trim)
      let plain = ($cur.exit_code == 0) and (not ($val | str contains (char nl))) and (not ($val | str contains '"')) and (not ($val | str contains '='))
      if $val != "" and (not $plain) {
        log warning $"mise: 跳过 ($key)，当前值含 tool 选项或多版本声明，保留用户配置"
        return
      }
      if $val == $want {
        return
      }
      let res = (do -i { ^${cfbin} config set --global $key $want } | complete)
      if $res.exit_code != 0 {
        log warning $"mise: 写入 ($key) 失败: ($res.stderr | str trim | str replace -a (char nl) ' ')"
      } else {
        log info $"mise: 已写入全局配置 ($key) = ($want)；安装请执行 mise install"
      }
    }
  '';

  # setting 值统一生成 nu 字符串字面量：def 的参数类型是 string，且 mise 会把 "false" 转成 bool
  # 注意：Nix 的 toString 对 bool 会得到 "" / "1"，必须显式映射成 true / false
  settingValue =
    key: value:
    nuValue "mise setting ${key} 的值" (
      if builtins.isBool value then (if value then "true" else "false") else value
    );

  settingsText = concatStringsSep "\n" (
    mapAttrsToList (
      key: value: "mise-nix-set-setting ${nuStr "mise setting 名" key} ${settingValue key value}"
    ) cfg.settings
  );

  toolText =
    name: value:
    let
      version = toolVersion name value;
    in
    if version == "" then
      ''
        log info "mise: 工具 ${validateName name} 只声明未指定版本，跳过全局配置写入"
      ''
    else
      ''
        mise-nix-set-tool ${nuKey (toolKey name)} ${nuValue "工具 ${validateName name} 的版本" version}
      '';

  toolsText = concatStringsSep "\n" (mapAttrsToList toolText tools);
in
{
  options.modules.dev.manager = with types; {
    enable = mkBoolOpt' true "是否使用 mise 管理开发语言版本";
    global = mkOption {
      description = "各工具写入 mise 全局配置时的默认版本";
      type = attrsOf str;
      default = { };
    };
    settings = mkOption {
      description = "写入 mise 全局配置的 settings，值可以是 bool 或字符串";
      type = attrsOf (oneOf [
        bool
        str
      ]);
      default = { };
    };
    package = mkPackageOption pkgs "mise" { };
    text = mkOpt' lines "" "追加到 init-dev 末尾的额外 nu 代码";
    prevInit = mkOpt' lines "" "在 mise 初始化之前执行的 nu 代码";
    extInit = mkOpt' lines "" "在 mise 配置写入之后执行的 nu 代码";
  };
  config = mkIf cfg.enable {
    # 默认关闭所有自动安装（逐键 mkDefault，用户设其它 setting 时不会丢失，也可单独覆盖）
    modules.dev.manager.settings = {
      auto_install = mkDefault false;
      exec_auto_install = mkDefault false;
      not_found_auto_install = mkDefault false;
    };
    home = {
      packages = [ cfg.package ];
      programs.bash.initExtra = ''
        eval "$(mise activate bash)"
      '';
    };
    modules.shell = {
      env.MISE_CACHE_DIR = miseCacheDir;
      zsh.rcInit = "_cache -v ${cfg.package.version} mise activate zsh";
      direnv.stdlib.mise = optionalNull cfm.shell.direnv.enable pkgs.writeScript "use_mise" ''
        #!/usr/bin/env sh
        ### Do not edit. This was autogenerated by 'mise direnv' ###
        use_mise() {
          direnv_load mise direnv exec
        }
      '';
      nushell.cacheCmd = [ "${cfbin} activate nu" ];
      fish.rcInit = "_cache -v${cfg.package.version} mise activate fish";
    };
    # 只写全局配置、不安装；安装交给用户执行 `mise install`
    my.user.init.init-dev = ''
      ${cfg.prevInit}
      $env.MISE_CACHE_DIR = "${miseCacheDir}"

      ${helperDefs}

      ${settingsText}
      ${toolsText}
      ${cfg.extInit}
      ${cfg.text}
    '';
  };
}
