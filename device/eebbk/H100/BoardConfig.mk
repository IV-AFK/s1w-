#
# TWRP / AOSP BoardConfig for EEBBK S1W (codename: H100)
# SoC: Unisoc (Spreadtrum) T310, 4x Cortex (1x A75 + 3x A55), PowerVR GPU
# Android 9 / SDK 28 / system-as-root / arm64-v8a + armeabi-v7a
#
DEVICE_PATH := device/eebbk/H100

# ---- Architecture -----------------------------------------------------------
TARGET_ARCH           := arm64
TARGET_ARCH_VARIANT   := armv8-a
TARGET_CPU_ABI        := arm64-v8a
TARGET_CPU_VARIANT    := cortex-a75
TARGET_CPU_VARIANT_RUNTIME := cortex-a75
TARGET_2ND_ARCH       := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI    := armeabi-v7a
TARGET_2ND_CPU_ABI2   := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_BOARD_PLATFORM           := sprd
TARGET_BOARD_PLATFORM_GPU       := powervr
TARGET_BOOTLOADER_BOARD_NAME    := H100
TARGET_NO_BOOTLOADER            := true

# ---- Kernel (prebuilt: stock raw arm64 Image, extracted from boot.img) ------
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
# The prebuilt is an *uncompressed* arm64 Image; arm64 defaults to Image.gz.
# Without this the build looks for a kernel artifact that does not exist.
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_CMDLINE   := console=ttyS1,115200n8 buildvariant=user
BOARD_KERNEL_PAGESIZE  := 2048

# values replicated from the stock boot header (kernel_addr / ramdisk_addr / tags_addr)
BOARD_KERNEL_BASE      := 0x00000000
BOARD_KERNEL_OFFSET    := 0x00008000
BOARD_RAMDISK_OFFSET   := 0x05400000
BOARD_TAGS_OFFSET      := 0x00000100

# stock header: header_version=1, os_version=0x12000139 -> Android 9.0.0 / 2019-09
BOARD_MKBOOTIMG_ARGS := --header_version 1 --os_version 9.0.0 --os_patch_level 2019-09

# ---- Partitions -------------------------------------------------------------
# `mka recoveryimage` only consumes *_RECOVERYIMAGE_PARTITION_SIZE.
# recovery = 40 MiB, dtbo = 8 MiB, confirmed from the 1:1 partition dumps.
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 41943040
BOARD_FLASH_BLOCK_SIZE            := 4096

# Replicate the stock recovery's embedded DT table (4838B, identical content to
# the dtbo partition) so the bootloader sees exactly the same image layout.
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_PREBUILT_DTBOIMAGE    := $(DEVICE_PATH)/prebuilt/recovery_dtbo.img

# Not consumed by a recovery-only build. Fill in only if you also build
# whole-disk images (system/vendor/userdata); left unset on purpose.
# BOARD_BOOTIMAGE_PARTITION_SIZE    :=
# BOARD_SYSTEMIMAGE_PARTITION_SIZE  :=
# BOARD_VENDORIMAGE_PARTITION_SIZE  :=
# BOARD_PRODUCTIMAGE_PARTITION_SIZE :=
# BOARD_CACHEIMAGE_PARTITION_SIZE   :=
# BOARD_USERDATAIMAGE_PARTITION_SIZE :=

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_USES_METADATA_PARTITION := false
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true

# ---- Recovery ---------------------------------------------------------------
TARGET_RECOVERY_FSTAB     := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_DEVICE_MODULES :=
TARGET_USES_ION           := true
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_SUPPRESS_SECURE_ERASE := true

# USB mass storage LUN (Unisoc configfs gadget)
TARGET_USE_CUSTOM_LUN_FILE_PATH := /config/usb_gadget/g1/functions/mass_storage.0/lun.%d/file

# ---- TWRP -------------------------------------------------------------------
TW_THEME := portrait_hdpi
TW_HAS_DOWNLOAD_MODE := false
# crypto needs vendor keymaster/libcrypto blobs we have not extracted yet;
# keep OFF so the build links, flip to true once vendor.img is available.
TW_INCLUDE_CRYPTO := false
TW_INCLUDE_FBE := false
TW_USE_TOOLBOX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_NO_SCREEN_BLANK := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := zh_CN
TW_DEVICE_VERSION := S1W-H100
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 128
TW_BRIGHTNESS_PATH := "/sys/class/backlight/sprd_backlight/brightness"
TW_INPUT_BLACKLIST := "hbtp_vm"
RECOVERY_SDCARD_ON_DATA := true
