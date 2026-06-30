# shared → dev → java

**源文件**: `modules/shared/dev/java.nix`  
**选项前缀**: `config.modules.dev.java`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | bool | false |  |
| `versions` | oneOf | [ ] | Use asdf to install java version |
| `global` | str | "" | java default version |

## 条件分支

- 当 `cfg.versions != [ ]` 为真时激活
- 当 `cfg.enable` 为真时激活

