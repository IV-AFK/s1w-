LOCAL_PATH := $(call my-dir)

# TWRP recovery fstab goes to the standard location; BoardConfig also sets
# TARGET_RECOVERY_FSTAB so the build system picks it up directly.
include $(CLEAR_VARS)
LOCAL_MODULE        := twrp_H100_fstab
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_CLASS  := ETC
LOCAL_SRC_FILES     := recovery.fstab
LOCAL_MODULE_PATH   := $(TARGET_RECOVERY_ROOT_OUT)/system/etc
include $(BUILD_PREBUILT)
