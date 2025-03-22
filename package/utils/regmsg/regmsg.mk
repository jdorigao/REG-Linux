################################################################################
#
# regmsg
#
################################################################################

REGMSG_VERSION = 9af157eca368af180ddb9b2ea8d06c995eea2902
REGMSG_SITE = $(call github,jdorigao,regmsg,$(REGMSG_VERSION))
REGMSG_LICENSE = MIT
REGMSG_LICENSE_FILES = LICENSE

ifeq ($(BR2_ENABLE_DEBUG),y)
REGMSG_LOCATION = target/$(RUSTC_TARGET_NAME)/debug
else
REGMSG_LOCATION = target/$(RUSTC_TARGET_NAME)/release
endif

define REGMSG_INSTALL_TARGET_CMDS
    	$(INSTALL) -D $(@D)/$(REGMSG_LOCATION)/regmsg	$(TARGET_DIR)/usr/bin/
	ln -sf regmsg $(TARGET_DIR)/usr/bin/system-resolution
endef

$(eval $(cargo-package))
