################################################################################
#
# sdl2_ttf
#
################################################################################

# REG bump
SDL2_TTF_VERSION = 2.24.0
SDL2_TTF_SOURCE = SDL2_ttf-$(SDL2_TTF_VERSION).tar.gz
SDL2_TTF_SITE = http://www.libsdl.org/projects/SDL_ttf/release
SDL2_TTF_LICENSE = Zlib
SDL2_TTF_LICENSE_FILES = LICENSE.txt
SDL2_TTF_INSTALL_STAGING = YES
SDL2_TTF_DEPENDENCIES = sdl2 freetype host-pkgconf
SDL2_TTF_CONF_OPTS = --disable-freetype-builtin --disable-harfbuzz-builtin

ifeq ($(BR2_PACKAGE_HARFBUZZ),y)
SDL2_TTF_DEPENDENCIES += harfbuzz
SDL2_TTF_CONF_OPTS += --enable-harfbuzz
else
SDL2_TTF_CONF_OPTS += --disable-harfbuzz
endif

# x-includes and x-libraries must be set for cross-compiling
# By default x_includes and x_libraries contains unsafe paths.
# (/usr/include and /usr/lib)
ifeq ($(BR2_PACKAGE_SDL2_X11),y)
SDL2_TTF_CONF_OPTS += \
	--with-x \
	--x-includes=$(STAGING_DIR)/usr/include \
	--x-libraries=$(STAGING_DIR)/usr/lib
else
SDL2_TTF_CONF_OPTS += \
	--without-x
endif

$(eval $(autotools-package))
