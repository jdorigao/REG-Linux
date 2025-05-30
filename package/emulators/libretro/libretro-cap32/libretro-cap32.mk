################################################################################
#
# libretro-cap32
#
################################################################################
# Version: Commits on May 7, 2025
LIBRETRO_CAP32_VERSION = a5d96c5ebbda3bc89a3bd1c1691a20f5eacc232d
LIBRETRO_CAP32_SITE = $(call github,libretro,libretro-cap32,$(LIBRETRO_CAP32_VERSION))
LIBRETRO_CAP32_LICENSE = GPLv2

LIBRETRO_CAP32_PLATFORM = $(LIBRETRO_PLATFORM)

ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2835),y)
LIBRETRO_CAP32_PLATFORM = rpi1

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2836),y)
LIBRETRO_CAP32_PLATFORM = rpi2

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2837),y)
LIBRETRO_CAP32_PLATFORM = rpi3_64

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2711),y)
LIBRETRO_CAP32_PLATFORM = rpi4

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2712),y)
LIBRETRO_CAP32_PLATFORM = rpi5

else ifeq ($(BR2_cortex_a35)$(BR2_cortex_a53)$(BR2_arm),yy)
LIBRETRO_CAP32_PLATFORM = armv neon
endif

define LIBRETRO_CAP32_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C $(@D)/ \
	    -f Makefile platform="$(LIBRETRO_CAP32_PLATFORM)" \
        GIT_VERSION="-$(shell echo $(LIBRETRO_CAP32_VERSION) | cut -c 1-7)"
endef

define LIBRETRO_CAP32_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib/libretro
	$(INSTALL) -D $(@D)/cap32_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/cap32_libretro.so
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp -f $(BR2_EXTERNAL_REGLINUX_PATH)/package/emulators/libretro/libretro-cap32/amstradcpc.keys \
	    $(TARGET_DIR)/usr/share/evmapy/
endef

$(eval $(generic-package))
