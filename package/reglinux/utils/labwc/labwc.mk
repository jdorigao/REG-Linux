################################################################################
#
# Labwc
#
################################################################################

LABWC_VERSION = 0.8.3
LABWC_SITE = $(call github,labwc,labwc,$(LABWC_VERSION))
LABWC_LICENSE = BSD 3-Clause
LABWC_LICENSE_FILES = LICENSE
LABWC_DEPENDENCIES = wlroots libxml2 libpng librsvg cairo pango

LABWC_CONF_OPTS = \
	-Dman-pages=disabled \
	-Dicon=disabled

$(eval $(meson-package))
