################################################################################
#
# regmsg
#
################################################################################

REGLINUX_MSG_VERSION = 68a787de3a7f282277866681ca3ffdbcda515e7d
REGLINUX_MSG_SITE = $(call github,jdorigao,regmsg,$(REGLINUX_MSG_VERSION))
REGLINUX_MSG_LICENSE = MIT
REGLINUX_MSG_LICENSE_FILES = LICENSE

ifeq ($(BR2_ENABLE_DEBUG),y)
REGLINUX_MSG_LOCATION = target/$(RUSTC_TARGET_NAME)/debug
else
REGLINUX_MSG_LOCATION = target/$(RUSTC_TARGET_NAME)/release
endif

define REGLINUX_MSG_INSTALL_TARGET_CMDS
    	$(INSTALL) -D $(@D)/$(REGLINUX_MSG_LOCATION)/regmsg	$(TARGET_DIR)/usr/bin/
	ln -sf regmsg $(TARGET_DIR)/usr/bin/system-resolution
endef

$(eval $(cargo-package))
