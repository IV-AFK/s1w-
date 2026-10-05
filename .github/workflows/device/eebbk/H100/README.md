# TWRP device tree — EEBBK S1W (codename `H100`)

逆向得出的设备信息与构建说明。

## 目标设备

| 项 | 值 |
|---|---|
| 型号 / 品牌 | S1W / EEBBK（步步高家教机） |
| 内部代号 | **H100**（`ro.product.device=H100`, `ro.product.name=H100_ctcc`） |
| 构建指纹 | `EEBBK/H100_ctcc/H100:9/PPR1.180610.011/V1.3.8_210831:user/release-keys` |
| SoC | 紫光展锐 **T310**（1×A75 + 3×A55），PowerVR GPU |
| 系统 | Android 9 / SDK 28 / **system-as-root**(`ro.build.system_root_image=true`) / arm64-v8a+armeabi-v7a |
| 屏幕 | 768×1024（`gt9xx touchscreen-size-x=0x300, -y=0x400`），Unisoc DPU + pwm-backlight |
| 触摸 | Goodix GT9xx @ i2c 0x14（备用 FocalTech FT5436） |
| 存储 | eMMC，SDIO 控制器 `71400000.sdio`；microSD 在 `71100000.sdio` |
| 无 | microSD 卡槽对系统不可见（`ro.build.characteristics=tablet,nosdcard`） |

## 镜像结构（逆向结果）

```
S1W_boot.img      header v1, page 2048, kernel=17127432B(裸 arm64 Image)
                  ramdisk_size=0, 无 dtb       <-- system-as-root
recovery.img      header v1, 同一 kernel, ramdisk=gzip 6093095B, recovery_dtbo=4838B
dtbo.img          DT table, 1 个 entry, DTB=4774B  <-- 是 overlay，不是基础 dtb
```

两个内核只差 4 字节（`0xd12876`）：
* boot 内核 → `skip_initramfs`
* recovery 内核 → **`want_initramfs`**  ← TWRP 用这个

## 目录内容

```
BoardConfig.mk        架构/内核/分区/TWRP 配置
twrp_H100.mk          product 配置（保留原厂指纹）
AndroidProducts.mk    lunch 目标注册
recovery.fstab        TWRP 格式分区表（源自原厂 /etc/recovery.fstab）
Android.mk            安装 recovery.fstab
prebuilt/Image        recovery 版内核（裸 arm64 Image，want_initramfs）
prebuilt/recovery_dtbo.img   原厂 recovery 内嵌的 DT table（4838B）
```

## 逆向工具（见 ../tools）

| 脚本 | 作用 |
|---|---|
| `recon.py` | 解析 boot header / dt_table，定位 kernel/ramdisk/dtb |
| `extract.py` | 拆 dtb、解 gzip+cpio、还原 ramdisk、输出 recovery.fstab |
| `fdt2dts.py` | FDT(.dtb) → .dts 反编译（替代 `dtc -I dtb -O dts`） |

产物在 `../work/`：`board.dtb`、`board.dts`、`recovery_root/`（完整 ramdisk）。

## 本地构建（需要 Linux + ≥100GB 磁盘）

```bash
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
repo sync -j8

# 放入 device tree
cp -r s1w/device/eebbk/H100  device/eebbk/H100

export ALLOW_MISSING_DEPENDENCIES=true
source build/envsetup.sh
lunch twrp_H100-eng
mka recoveryimage -j$(nproc)
# -> out/target/product/H100/recovery.img
```

## 在 CI 上构建（不需要本地 Linux）

仓库已带 `.github/workflows/build-twrp.yml`。本机磁盘不够（C: 17.5GB / D: 8.3GB），
但 CI 上可以零成本跑：

1. 在 GitHub 建一个 **public** 仓库
2. 推送整个 `s1w/`（`.gitignore` 已排除 `work/`）
3. 仓库 → Actions → `Build TWRP for EEBBK S1W (H100)` → Run workflow
4. 跑完在 Artifacts 下载 `twrp-H100-recovery`（内含 `recovery.img`）

workflow 会先删掉 runner 上用不到的 SDK/工具链腾出 ~40GB——官方 runner
默认只有 14GB，装不下 TWRP 9.0 源码树。编译失败会自动上传 `out/*.log`。

## 刷入

本机无 BL 锁。有 Magisk root，可直接 dd：

```bash
adb push recovery.img /data/local/tmp/
adb shell su -c "dd if=/data/local/tmp/recovery.img of=/dev/block/platform/soc/soc:ap-apb/71400000.sdio/by-name/recovery"
```

或用 fastboot：`fastboot flash recovery recovery.img`

## 构建输入完整性

最初担心的三样，核实后**都不阻塞**：

| 项 | 结论 | 依据 |
|---|---|---|
| 各分区大小 | **不阻塞** | `mka recoveryimage` 只消费 `BOARD_RECOVERYIMAGE_PARTITION_SIZE`（=41943040，已从 dump 确认） |
| 基础 dtb（`dtb` 分区） | **不需要** | 原厂 `recovery.img` 也没内嵌基础 dtb，只有 `recovery_dtbo`（已提取为 `prebuilt/recovery_dtbo.img`） |
| PowerVR gralloc | **不需要** | 原厂 recovery 用 minui + DRM(`/dev/dri/card0`) + fb0 兜底，全程无 gralloc/hwcomposer |

## 验证

用逆向参数重建 boot 镜像，与原厂逐字节对比：

```
rebuilt 23231206B vs source slot 41943040B
differing bytes: 5   (0x671..0x677)
```

那 5 字节位于 v1 头（1648）之后的 **header 页填充区**；`header_size` 字段=1648，
bootloader 不读取 → 惰性。kernel / ramdisk / recovery_dtbo 的偏移与对齐、
`page_size=2048`、`header_version=1`、`os_version=0x12000139`(Android 9.0.0 / 2019-09) 全部一致。

另外 `TW_BRIGHTNESS_PATH` 与原厂 recovery 内嵌的
`/sys/class/backlight/sprd_backlight/brightness` 完全一致。

## 还没做的

* 真正编译（需 Linux + TWRP 9.0 源码树，~50GB，本机 Windows 环境做不了）。
* 加密：`TW_INCLUDE_CRYPTO` 已关。要开需从 `vendor` 分区取 keymaster/libcrypto blob。
* 外部 microSD 显示名/挂载点需上机实测。
