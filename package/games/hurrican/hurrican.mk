################################################################################
#
# hurrican
#
################################################################################
# Version: Commits on Jul 25, 2025
HURRICAN_VERSION = 9933cbe887aaa2c75e723ba6322942fec2b838e7
HURRICAN_SITE = https://github.com/HurricanGame/Hurrican

HURRICAN_DEPENDENCIES = sdl2 sdl2_mixer sdl2_image libepoxy libopenmpt
HURRICAN_SITE_METHOD=git
HURRICAN_GIT_SUBMODULES=YES
HURRICAN_LICENSE = GPL-2.0

HURRICAN_SUPPORTS_IN_SOURCE_BUILD = NO

HURRICAN_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release $(@D)/Hurrican -DRENDERER=GLES2

define HURRICAN_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/hurrican/
	cp -pvr $(@D)/buildroot-build/hurrican $(TARGET_DIR)/usr/bin
	chmod 0755 $(TARGET_DIR)/usr/bin/hurrican
	# evmap config
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp $(BR2_EXTERNAL_REGLINUX_PATH)/package/games/hurrican/hurrican.keys \
	    $(TARGET_DIR)/usr/share/evmapy
endef

$(eval $(cmake-package))
