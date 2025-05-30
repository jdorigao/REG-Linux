################################################################################
#
# play!
#
################################################################################
PLAY_VERSION = 0.70
PLAY_SITE = https://github.com/jpd002/Play-.git
PLAY_SITE_METHOD = git
PLAY_GIT_SUBMODULES = YES
PLAY_LICENSE = BSD

PLAY_DEPENDENCIES = openal reglinux-qt6 sqlite ecm

PLAY_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release
PLAY_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF
PLAY_CONF_OPTS += -DINSTALL_STATIC_LIBS=ON
PLAY_CONF_OPTS += -DBUILD_TESTS=OFF
PLAY_CONF_OPTS += -DENABLE_AMAZON_S3=OFF

ifeq ($(BR2_PACKAGE_REGLINUX_XWAYLAND),y)
    PLAY_DEPENDENCIES += xwayland libgl libglew libglu
ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_X86_64_ANY),y)
    PLAY_CONF_OPTS += -DOpenGL_GL_PREFERENCE=GLVND
endif
else
    # Force to use GLES on ARM (Wayland)
    PLAY_CONF_OPTS += -DUSE_GLEW=OFF
    PLAY_CONF_OPTS += -DUSE_GLES=ON
    PLAY_DEPENDENCIES += libgles
endif

ifeq ($(BR2_PACKAGE_REGLINUX_VULKAN),y)
    PLAY_DEPENDENCIES += vulkan-headers vulkan-loader
endif

define PLAY_EVMAPY
	# evmap config
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp $(BR2_EXTERNAL_REGLINUX_PATH)/package/emulators/play/*.keys \
	    $(TARGET_DIR)/usr/share/evmapy
endef

PLAY_POST_INSTALL_TARGET_HOOKS += PLAY_EVMAPY

$(eval $(cmake-package))
