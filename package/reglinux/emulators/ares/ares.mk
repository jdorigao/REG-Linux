################################################################################
#
# ares
#
################################################################################
# Version.: Release on Feb 5, 2025
ARES_VERSION = v142
ARES_SITE = $(call github,ares-emulator,ares,$(ARES_VERSION))
ARES_LICENSE = GPLv3
ARES_DEPENDENCIES = sdl2 libgl zlib pango cairo libgtk3 librashader xwayland

ARES_SUPPORTS_IN_SOURCE_BUILD = NO

ARES_CONF_OPTS  = -DCMAKE_BUILD_TYPE=Release
ARES_CONF_OPTS += -DBUILD_SHARED_LIBS=FALSE
ARES_CONF_OPTS += -DWITH_SYSTEM_ZLIB=ON
ARES_CONF_OPTS += -DARES_BUILD_LOCAL=OFF
ARES_CONF_OPTS += -DARES_ENABLE_MINIMUM_CPU=OFF

$(eval $(cmake-package))
