# hardware (含 test + phil)

**源文件**: `modules/hardware/test.nix`、`modules/hardware/phil.nix`  
**选项前缀**: 无自定义选项（直接配置 NixOS 硬件/引导）

> NixOS 硬件配置模块，由 `nixos-generate-config` 生成或手动编写。

## test.nix — 通用测试硬件

轻量级硬件配置，用于虚拟机或测试环境。

| 配置 | 值 | 说明 |
|------|------|------|
| `boot.kernelPackages` | `linux_6_1` (mkDefault) | Linux 6.1 内核 |
| `boot.loader.efi.canTouchEfiVariables` | true (mkDefault) | 允许 EFI 变量修改 |
| `boot.loader.systemd-boot.enable` | true (mkDefault) | 使用 systemd-boot |
| `boot.loader.systemd-boot.configurationLimit` | 10 | 最多保留 10 个启动项 |

## phil.nix — Phil 机器硬件

> ⚠️ 由 `nixos-generate-config` 自动生成，勿手动修改。

### 内核模块

| 阶段 | 模块 |
|------|------|
| initrd.availableKernelModules | `xhci_pci`, `ahci`, `usb_storage`, `sd_mod`, `rtsx_pci_sdmmc` |
| initrd.kernelModules | _(空)_ |
| kernelModules | `kvm-intel` |

### 文件系统

| 挂载点 | 设备 | 类型 |
|--------|------|------|
| `/` | `/dev/disk/by-uuid/0e79aab0-c525-49e2-8969-881775ee6aab` | ext4 |

### Swap

- `/dev/disk/by-uuid/290950fc-6304-4dfb-b147-9759d19b36ff`

### 电源管理

- `powerManagement.cpuFreqGovernor` = `"powersave"` (mkDefault)
