################################################################################
#
# REG-Linux bezels
#
################################################################################
# Version.: Commits on Mar 18, 2023
REGLINUX_BEZELS_VERSION = 6fec5f21bb31dc1b1e44fa3ad7d246c13bc40892
REGLINUX_BEZELS_SITE = $(call github,REG-Linux,REG-bezel,$(REGLINUX_BEZELS_VERSION))

define REGLINUX_BEZELS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/ambiance_broadcast	      $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/ambiance_gameroom 	      $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/ambiance_monitor_1084s   $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/ambiance_night           $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/ambiance_vintage_tv      $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/arcade_1980s             $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/arcade_1980s_vertical    $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	cp -rf $(@D)/arcade_vertical_default  $(TARGET_DIR)/usr/share/reglinux/datainit/decorations
	mkdir -p $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/consoles
	# we don't have all systems with no_curve_night yet, so we copy first the "classic" bezels
	cp -rf --remove-destination $(@D)/default_unglazed/*               $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/consoles/
	cp -rf --remove-destination $(@D)/default_nocurve_night/default.*  $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/consoles/
	cp -rf --remove-destination $(@D)/default_nocurve_night/systems    $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/consoles/
	cp -rf --remove-destination $(@D)/default_standalone_night/systems $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/consoles/
	(cd $(TARGET_DIR)/usr/share/reglinux/datainit/decorations && ln -sf consoles default)

	echo -e "You can find help on how to customize decorations: \n" \
		> $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/readme.txt
	echo "https://wiki.batocera.org/decoration#decoration_bezels_customization" \
		>> $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/readme.txt
	echo "You can put standalone bezels here too." \
		>> $(TARGET_DIR)/usr/share/reglinux/datainit/decorations/readme.txt

endef

$(eval $(generic-package))

