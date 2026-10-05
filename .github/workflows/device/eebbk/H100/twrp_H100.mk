#
# TWRP product config: EEBBK S1W (H100)
#
$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_DEVICE       := H100
PRODUCT_NAME         := twrp_H100
PRODUCT_BRAND        := EEBBK
PRODUCT_MODEL        := S1W
PRODUCT_MANUFACTURER := EEBBK
PRODUCT_RELEASE_NAME := H100

# keep the stock fingerprint so OTA/verity tooling recognises the device
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=H100_ctcc \
    BUILD_FINGERPRINT="EEBBK/H100_ctcc/H100:9/PPR1.180610.011/V1.3.8_210831:user/release-keys" \
    PRIVATE_BUILD_DESC="H100_ctcc-user 9 PPR1.180610.011 V1.3.8_210831 release-keys"
