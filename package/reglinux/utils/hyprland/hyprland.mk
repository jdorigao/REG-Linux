################################################################################
#
# Hyprland
#
################################################################################

HYPRLAND_VERSION = v0.43.0
HYPRLAND_SITE = $(call github,hyprwm,Hyprland,$(HYPRLAND_VERSION))
HYPRLAND_LICENSE = BSD 3-Clause
HYPRLAND_LICENSE_FILES = LICENSE
HYPRLAND_DEPENDENCIES = cairo pango

$(eval $(meson-package))
