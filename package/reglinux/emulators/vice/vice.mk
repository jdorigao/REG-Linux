################################################################################
#
# vice
#
################################################################################

VICE_VERSION = 3.9
VICE_SOURCE = vice-$(VICE_VERSION).tar.gz
VICE_SITE = https://sourceforge.net/projects/vice-emu/files/releases
VICE_LICENSE = GPLv2
#VICE_DEPENDENCIES = ffmpeg
VICE_DEPENDENCIES = sdl2 libpng giflib zlib lame alsa-lib jpeg host-xa
VICE_DEPENDENCIES += host-dos2unix sdl2_image libcurl mpg123 libvorbis

VICE_CONF_OPTS += --disable-option-checking
VICE_CONF_OPTS += --enable-midi
VICE_CONF_OPTS += --with-lame
VICE_CONF_OPTS += --with-vorbis
VICE_CONF_OPTS += --with-flac
VICE_CONF_OPTS += --with-mpg123
VICE_CONF_OPTS += --with-evdev
VICE_CONF_OPTS += --with-alsa
VICE_CONF_OPTS += --with-zlib
VICE_CONF_OPTS += --with-jpeg
VICE_CONF_OPTS += --with-gif
VICE_CONF_OPTS += --with-png
VICE_CONF_OPTS += --with-fastsid
VICE_CONF_OPTS += --without-pulse
VICE_CONF_OPTS += --enable-x64
VICE_CONF_OPTS += --enable-arch=yes
VICE_CONF_OPTS += --enable-sdl2ui
VICE_CONF_OPTS += --with-sdlsound
VICE_CONF_OPTS += --disable-debug-gtk3ui
VICE_CONF_OPTS += --disable-html-docs
VICE_CONF_OPTS += --disable-pdf-docs
# needs old ffmpeg 4.x
#VICE_CONF_OPTS += --enable-ffmpeg

VICE_CONF_ENV += LDFLAGS=-lSDL2

define VICE_POST_PROCESS
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp -f $(BR2_EXTERNAL_REGLINUX_PATH)/package/reglinux/emulators/vice/c64.vice.keys \
        $(TARGET_DIR)/usr/share/evmapy
	cp -f $(BR2_EXTERNAL_REGLINUX_PATH)/package/reglinux/emulators/vice/c128.vice.keys \
        $(TARGET_DIR)/usr/share/evmapy
endef

VICE_POST_INSTALL_TARGET_HOOKS += VICE_POST_PROCESS

$(eval $(autotools-package))
