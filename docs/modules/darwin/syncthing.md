# darwin → syncthing

**源文件**: `modules/darwin/syncthing.nix`  
**选项前缀**: `config.modules.darwin.syncthing`

## 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enable` | types.bool | false | Whether to enable the Syncthing service. |
| `homeDir` | types.nullOr | "~" | the base location for the syncthing folder |
| `logDir` | types.nullOr | "~/Library/Logs" | The logfile to use for the Syncthing service. |

