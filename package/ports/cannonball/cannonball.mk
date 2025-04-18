################################################################################
#
# cannonball
#
################################################################################
# Version.: Commits on Jun 24, 2020
CANNONBALL_VERSION = b6aa525ddd552f96b43b3b3a6f69326a277206bd
CANNONBALL_SITE = $(call github,djyt,cannonball,$(CANNONBALL_VERSION))
CANNONBALL_LICENSE = GPLv2
CANNONBALL_DEPENDENCIES = sdl2 boost

CANNONBALL_TARGET = sdl2gles

ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2835),y)
CANNONBALL_TARGET = sdl2gles_rpi
CANNONBALL_RPI = -mcpu=arm1176jzf-s -mfloat-abi=hard
else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2836),y)
CANNONBALL_TARGET = sdl2gles_rpi
CANNONBALL_RPI = -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard
else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2837),y)
CANNONBALL_TARGET = sdl2gles_rpi
CANNONBALL_RPI = -march=armv8-a+crc -mcpu=cortex-a53
else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2711),y)
CANNONBALL_TARGET = sdl2gles_rpi
CANNONBALL_RPI = -march=armv8-a+crc -mcpu=cortex-a72
else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2712),y)
CANNONBALL_TARGET = sdl2gles_rpi
CANNONBALL_RPI = -mcpu=cortex-a76 -mtune=cortex-a76
else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_X86),y)
CANNONBALL_TARGET = sdl2gl
else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_X86_64_ANY),y)
CANNONBALL_TARGET = sdl2gl
endif

# Build as release with proper target and paths
CANNONBALL_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release -DTARGET=$(CANNONBALL_TARGET)
CANNONBALL_CONF_OPTS += -DBUILD_STATIC_LIBS=ON
CANNONBALL_CONF_OPTS += -DBUILD_SHARED_LIBS=ON
CANNONBALL_CONF_OPTS += -Droms_directory=/userdata/roms/cannonball/
CANNONBALL_CONF_OPTS += -Dxml_directory=/userdata/system/configs/cannonball/
CANNONBALL_CONF_OPTS += -Dres_directory=/userdata/system/configs/cannonball/


# Enabling LTO as hires mode tends to be slow, it does help video rendering loops
CANNONBALL_EXE_LINKER_FLAGS += -flto=auto
CANNONBALL_SHARED_LINKER_FLAGS += -flto=auto
CANNONBALL_CONF_OPTS += -DCMAKE_CXX_FLAGS=-flto=auto
CANNONBALL_CONF_OPTS += -DCMAKE_EXE_LINKER_FLAGS="$(CANNONBALL_EXE_LINKER_FLAGS)"
CANNONBALL_CONF_OPTS += -DCMAKE_SHARED_LINKER_FLAGS="$(CANNONBALL_SHARED_LINKER_FLAGS)"

# We need to build out-of-tree
CANNONBALL_SUPPORTS_IN_SOURCE_BUILD = NO

define CANNONBALL_SETUP_CMAKE
	cp $(@D)/cmake/* $(@D)/
	$(SED) "s+../res/config+\./res/config+g" $(@D)/CMakeLists.txt
	$(SED) "s+../src/main+\./src/main+g" $(@D)/CMakeLists.txt
	$(SED) "s+../res/tilemap.bin+\./res/tilemap.bin +g" $(@D)/CMakeLists.txt
	$(SED) "s+../res/tilepatch.bin+\./res/tilepatch.bin +g" $(@D)/CMakeLists.txt
        $(SED) "s+/usr+$(STAGING_DIR)/usr+g" $(@D)/CMakeLists.txt
        $(SED) "s+/usr+$(STAGING_DIR)/usr+g" $(@D)/sdl2.cmake
        $(SED) "s+/usr+$(STAGING_DIR)/usr+g" $(@D)/sdl2gl.cmake
        $(SED) "s+/usr+$(STAGING_DIR)/usr+g" $(@D)/sdl2gles.cmake
        $(SED) "s+/usr+$(STAGING_DIR)/usr+g" $(@D)/sdl2gles_rpi.cmake
    # Rpi compilation
    $(SED) 's|-mcpu=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard|$(CANNONBALL_RPI)|g' $(@D)/sdl2gles_rpi.cmake
endef

CANNONBALL_PRE_CONFIGURE_HOOKS += CANNONBALL_SETUP_CMAKE

define CANNONBALL_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/buildroot-build/cannonball $(TARGET_DIR)/usr/bin/
	mkdir -p $(TARGET_DIR)/usr/share/reglinux/datainit/system/configs/cannonball/res/
	$(INSTALL) -D $(@D)/buildroot-build/res/tilemap.bin \
	    $(TARGET_DIR)/usr/share/reglinux/datainit/system/configs/cannonball/
	$(INSTALL) -D $(@D)/buildroot-build/res/tilepatch.bin \
	    $(TARGET_DIR)/usr/share/reglinux/datainit/system/configs/cannonball/
	$(INSTALL) -D $(@D)/buildroot-build/config.xml \
	    $(TARGET_DIR)/usr/share/reglinux/datainit/system/configs/cannonball/config_help.txt
endef

$(eval $(cmake-package))
