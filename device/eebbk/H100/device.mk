#
# EEBBK S1W (H100) product makefile.
#
# A recovery-only build needs no vendor blobs, so this file is deliberately
# thin: it exists because twrp_H100.mk inherits it, and it pulls in the fstab
# module from Android.mk so a missing/incorrect partition table shows up as a
# build error rather than as a recovery that silently sees no partitions.
#
PRODUCT_PACKAGES += \
    twrp_H100_fstab
