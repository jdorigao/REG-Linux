################################################################################
#
# xemu
#
################################################################################
# Version: Commits on Jul 20, 2025
XEMU_VERSION = v0.8.95
XEMU_SITE = https://github.com/xemu-project/xemu.git
XEMU_SITE_METHOD = git
XEMU_GIT_SUBMODULES = YES
XEMU_LICENSE = GPLv2
XEMU_DEPENDENCIES = host-meson host-cmake host-pkgconf host-python3 host-python-distlib
XEMU_DEPENDENCIES += host-libcurl libcurl libglib2 zlib sdl2 libsamplerate slirp host-python-pyyaml
XEMU_DEPENDENCIES += libpcap libepoxy libgtk3 json-for-modern-cpp

XEMU_EXTRA_DOWNLOADS = https://github.com/mborgerson/xemu-hdd-image/releases/download/1.0/xbox_hdd.qcow2.zip

XEMU_CONF_ENV += PATH="/$(BR2_ARCH)/host/$(BR2_ARCH)-buildroot-linux-gnu/sysroot/usr/bin:$$PATH"

XEMU_CONF_OPTS += --target-list=i386-softmmu
XEMU_CONF_OPTS += --cross-prefix="$(STAGING_DIR)"
XEMU_CONF_OPTS += --extra-cflags="-DXBOX=1 -O3 -Wno-error=redundant-decls -Wno-error=unused-but-set-variable"
XEMU_CONF_OPTS += --extra-ldflags=""
XEMU_CONF_OPTS += --enable-sdl
XEMU_CONF_OPTS += --enable-opengl
XEMU_CONF_OPTS += --enable-trace-backends="nop"
XEMU_CONF_OPTS += --disable-kvm
XEMU_CONF_OPTS += --disable-xen
XEMU_CONF_OPTS += --disable-werror
XEMU_CONF_OPTS += --disable-curl
XEMU_CONF_OPTS += --disable-vnc
XEMU_CONF_OPTS += --disable-vnc-sasl
XEMU_CONF_OPTS += --disable-docs
XEMU_CONF_OPTS += --disable-tools
XEMU_CONF_OPTS += --disable-guest-agent
XEMU_CONF_OPTS += --disable-tpm
XEMU_CONF_OPTS += --disable-rdma
XEMU_CONF_OPTS += --disable-replication
XEMU_CONF_OPTS += --disable-capstone
XEMU_CONF_OPTS += --disable-libiscsi
XEMU_CONF_OPTS += --disable-spice
XEMU_CONF_OPTS += --disable-user
XEMU_CONF_OPTS += --disable-stack-protector
XEMU_CONF_OPTS += --disable-glusterfs
XEMU_CONF_OPTS += --disable-curses
XEMU_CONF_OPTS += --disable-gnutls
XEMU_CONF_OPTS += --disable-nettle
XEMU_CONF_OPTS += --disable-gcrypt
XEMU_CONF_OPTS += --disable-crypto-afalg
XEMU_CONF_OPTS += --disable-virglrenderer
XEMU_CONF_OPTS += --disable-vhost-net
XEMU_CONF_OPTS += --disable-vhost-crypto
XEMU_CONF_OPTS += --disable-vhost-user
XEMU_CONF_OPTS += --disable-virtfs
XEMU_CONF_OPTS += --disable-snappy
XEMU_CONF_OPTS += --disable-bzip2
XEMU_CONF_OPTS += --disable-vde
XEMU_CONF_OPTS += --disable-seccomp
XEMU_CONF_OPTS += --disable-numa
XEMU_CONF_OPTS += --disable-lzo
XEMU_CONF_OPTS += --disable-smartcard
XEMU_CONF_OPTS += --disable-usb-redir
XEMU_CONF_OPTS += --disable-bochs
XEMU_CONF_OPTS += --disable-cloop
XEMU_CONF_OPTS += --disable-dmg
XEMU_CONF_OPTS += --disable-vdi
XEMU_CONF_OPTS += --disable-vvfat
XEMU_CONF_OPTS += --disable-qcow1
XEMU_CONF_OPTS += --disable-qed
XEMU_CONF_OPTS += --disable-parallels
XEMU_CONF_OPTS += --disable-hvf
XEMU_CONF_OPTS += --disable-whpx
XEMU_CONF_OPTS += --with-default-devices
XEMU_CONF_OPTS += --disable-renderdoc

# Vulkan
ifeq ($(BR2_PACKAGE_REGLINUX_VULKAN),y)
XEMU_DEPENDENCIES += vulkan-headers vulkan-loader
endif

# AVX2 is only available on x86_64_v3 or more
ifeq ($(BR2_x86_x86_64_v3),y)
XEMU_CONF_OPTS += --enable-avx2
else
XEMU_CONF_OPTS += --disable-avx2
endif

define XEMU_CONFIGURE_CMDS
	cd $(@D) && $(TARGET_CONFIGURE_OPTS) ./configure $(XEMU_CONF_OPTS)
endef

define XEMU_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" \
		CC_FOR_BUILD="$(TARGET_CC)" GCC_FOR_BUILD="$(TARGET_CC)" \
		CXX_FOR_BUILD="$(TARGET_CXX)" LD_FOR_BUILD="$(TARGET_LD)" \
		    CROSS_COMPILE="$(STAGING_DIR)/usr/bin/" \
            PREFIX="/$(BR2_ARCH)/host/$(BR2_ARCH)-buildroot-linux-gnu/sysroot/" \
            PKG_CONFIG="/$(BR2_ARCH)/host/$(BR2_ARCH)-buildroot-linux-gnu/sysroot/usr/bin/pkg-config" \
		$(MAKE) -C $(@D)
endef

define XEMU_INSTALL_TARGET_CMDS
	# Binaries
	cp $(@D)/build/qemu-system-i386 $(TARGET_DIR)/usr/bin/xemu

	# XEmu app data
	mkdir -p $(TARGET_DIR)/usr/share/xemu/data
	cp $(@D)/data/* $(TARGET_DIR)/usr/share/xemu/data/
	$(UNZIP) -ob $(XEMU_DL_DIR)/xbox_hdd.qcow2.zip xbox_hdd.qcow2 -d \
	    $(TARGET_DIR)/usr/share/xemu/data
endef

define XEMU_VERSION_DETAILS
    $(BR2_GIT) -C $(XEMU_DL_DIR)/git rev-parse HEAD 2>/dev/null | tr -d '\n' > $(@D)/XEMU_COMMIT
    $(BR2_GIT) -C $(XEMU_DL_DIR)/git symbolic-ref --short HEAD | cut -d'/' -f2- > $(@D)/XEMU_BRANCH
    $(BR2_GIT) -C $(XEMU_DL_DIR)/git describe --tags --match 'v*' | cut -c 2- | tr -d '\n' > $(@D)/XEMU_VERSION
endef

# details in the .wrap files
define XEMU_GET_SUBMODULES
    # imgui
    mkdir -p $(@D)/subprojects/imgui
    $(eval REVISION = $(shell grep -Po '(?<=^revision=).+' $(@D)/subprojects/imgui.wrap))
    $(HOST_DIR)/bin/curl -L -o imgui.tar.gz \
        https://github.com/xemu-project/imgui/archive/$(REVISION).tar.gz
    $(TAR) -xzf imgui.tar.gz --strip-components=1 -C $(@D)/subprojects/imgui
    rm imgui.tar.gz

	# implot
	mkdir -p $(@D)/subprojects/implot
    $(eval REVISION = $(shell grep -Po '(?<=^revision=).+' $(@D)/subprojects/implot.wrap))
	$(HOST_DIR)/bin/curl -L -o implot.tar.gz \
	    https://github.com/xemu-project/implot/archive/$(REVISION).tar.gz
	$(TAR) -xzf implot.tar.gz --strip-components=1 -C $(@D)/subprojects/implot
	rm implot.tar.gz

	# genconfig
	mkdir -p $(@D)/subprojects/genconfig
    $(eval REVISION = $(shell grep -Po '(?<=^revision=).+' $(@D)/subprojects/genconfig.wrap))
	$(HOST_DIR)/bin/curl -L -o genconfig.tar.gz \
	    https://github.com/mborgerson/genconfig/archive/$(REVISION).tar.gz
	$(TAR) -xzf genconfig.tar.gz --strip-components=1 -C $(@D)/subprojects/genconfig
	rm genconfig.tar.gz

    # tomlplusplus
	mkdir -p $(@D)/subprojects/tomlplusplus
 #   $(eval REVISION = $(shell grep -Po '(?<=^revision=).+' $(@D)/subprojects/tomlplusplus.wrap))
	$(HOST_DIR)/bin/curl -L -o tomlplusplus.tar.gz \
	    https://github.com/marzer/tomlplusplus/archive/refs/tags/v3.4.0.tar.gz
	$(TAR) -xzf tomlplusplus.tar.gz --strip-components=1 -C $(@D)/subprojects/tomlplusplus
	rm tomlplusplus.tar.gz

    # glslang
	mkdir -p $(@D)/subprojects/glslang
#    $(eval REVISION = $(shell grep -Po '(?<=^revision=).+' $(@D)/subprojects/glslang.wrap))
	$(HOST_DIR)/bin/curl -L -o glslang.tar.gz \
	    https://github.com/KhronosGroup/glslang/archive/refs/tags/15.3.0.tar.gz
	#https://github.com/KhronosGroup/glslang/archive/$(REVISION).tar.gz
	$(TAR) -xzf glslang.tar.gz --strip-components=1 -C $(@D)/subprojects/glslang
	rm glslang.tar.gz

    # xxhash
	mkdir -p $(@D)/subprojects/xxHash-0.8.3
	$(HOST_DIR)/bin/curl -L -o xxhash.tar.gz \
	    http://github.com/mesonbuild/wrapdb/releases/download/xxhash_0.8.3-1/xxHash-0.8.3.tar.gz
	$(TAR) -xzf xxhash.tar.gz --strip-components=1 -C $(@D)/subprojects/xxHash-0.8.3
	rm xxhash.tar.gz

    # xxhash patch
	$(HOST_DIR)/bin/curl -L -o xxhash_0.8.3-1_patch.zip \
	    https://wrapdb.mesonbuild.com/v2/xxhash_0.8.3-1/get_patch
	$(UNZIP) -o xxhash_0.8.3-1_patch.zip -d $(@D)/subprojects
	rm xxhash_0.8.3-1_patch.zip

    # keycodemapdb - revision variation
	mkdir -p $(@D)/subprojects/keycodemapdb
    $(eval REVISION = $(shell grep -Po '(?<=^revision = ).+' $(@D)/subprojects/keycodemapdb.wrap))
    $(HOST_DIR)/bin/curl -L -o keycodemapdb.tar.gz \
	    https://gitlab.com/qemu-project/keycodemapdb/-/archive/$(REVISION)/$(REVISION).tar.gz
	$(TAR) -xzf keycodemapdb.tar.gz --strip-components=1 -C $(@D)/subprojects/keycodemapdb
	rm keycodemapdb.tar.gz

    # nv2a_vsh_cpu
	mkdir -p $(@D)/subprojects/nv2a_vsh_cpu
    $(eval REVISION = $(shell grep -Po '(?<=^revision=).+' $(@D)/subprojects/nv2a_vsh_cpu.wrap))
	$(HOST_DIR)/bin/curl -L -o nv2a_vsh_cpu.tar.gz \
	    https://github.com/xemu-project/nv2a_vsh_cpu/archive/$(REVISION).tar.gz
	$(TAR) -xzf nv2a_vsh_cpu.tar.gz --strip-components=1 -C $(@D)/subprojects/nv2a_vsh_cpu
	rm nv2a_vsh_cpu.tar.gz

    # berkeley-softfloat-3 - revision variation
	mkdir -p $(@D)/subprojects/berkeley-softfloat-3
 #   $(eval REVISION = $(shell grep -Po '(?<=^revision = ).+' $(@D)/subprojects/berkeley-softfloat-3.wrap))
	$(HOST_DIR)/bin/curl -L -o berkeley-softfloat-3.tar.gz \
	    https://gitlab.com/qemu-project/berkeley-softfloat-3/-/archive/master/berkeley-softfloat-3-master.tar.gz
#https://gitlab.com/qemu-project/berkeley-softfloat-3/-/archive/$(REVISION)/$(REVISION).tar.gz
	$(TAR) -xzf berkeley-softfloat-3.tar.gz --strip-components=1 -C $(@D)/subprojects/berkeley-softfloat-3
	cp $(@D)/subprojects/packagefiles/berkeley-softfloat-3/* $(@D)/subprojects/berkeley-softfloat-3
	rm berkeley-softfloat-3.tar.gz

    # berkeley-testfloat-3 - revision variation
	mkdir -p $(@D)/subprojects/berkeley-testfloat-3
    $(eval REVISION = $(shell grep -Po '(?<=^revision = ).+' $(@D)/subprojects/berkeley-testfloat-3.wrap))
	$(HOST_DIR)/bin/curl -L -o berkeley-testfloat-3.tar.gz \
	    https://gitlab.com/qemu-project/berkeley-testfloat-3/-/archive/$(REVISION)/$(REVISION).tar.gz
	$(TAR) -xzf berkeley-testfloat-3.tar.gz --strip-components=1 -C $(@D)/subprojects/berkeley-testfloat-3
	cp $(@D)/subprojects/packagefiles/berkeley-testfloat-3/* $(@D)/subprojects/berkeley-testfloat-3
	rm berkeley-testfloat-3.tar.gz

    # volk
	mkdir -p $(@D)/subprojects/volk
    #$(eval REVISION = $(shell grep -Po '(?<=^revision=).+' $(@D)/subprojects/volk.wrap))
	$(HOST_DIR)/bin/curl -L -o volk.tar.gz \
	    https://github.com/zeux/volk/archive/refs/tags/1.4.304.tar.gz
	#https://github.com/zeux/volk/-/archive/$(REVISION)/$(REVISION).tar.gz
	$(TAR) -xzf volk.tar.gz --strip-components=1 -C $(@D)/subprojects/volk
	rm volk.tar.gz

    # SPIRV-Reflect
	mkdir -p $(@D)/subprojects/SPIRV-Reflect
	$(HOST_DIR)/bin/curl -L -o SPIRV-Reflect.tar.gz \
	https://github.com/KhronosGroup/SPIRV-Reflect/archive/refs/tags/vulkan-sdk-1.4.313.0.tar.gz
	$(TAR) -xzf SPIRV-Reflect.tar.gz --strip-components=1 -C $(@D)/subprojects/SPIRV-Reflect
	rm SPIRV-Reflect.tar.gz

    # VulkanMemoryAllocator
	mkdir -p $(@D)/subprojects/VulkanMemoryAllocator
	$(HOST_DIR)/bin/curl -L -o VulkanMemoryAllocator.tar.gz \
	https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/v3.3.0.tar.gz
	$(TAR) -xzf VulkanMemoryAllocator.tar.gz --strip-components=1 -C $(@D)/subprojects/VulkanMemoryAllocator
	rm VulkanMemoryAllocator.tar.gz

endef

define XEMU_EVMAPY
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp $(BR2_EXTERNAL_REGLINUX_PATH)/package/emulators/xemu/*.keys \
	    $(TARGET_DIR)/usr/share/evmapy
endef

XEMU_PRE_CONFIGURE_HOOKS = XEMU_VERSION_DETAILS
XEMU_POST_INSTALL_TARGET_HOOKS += XEMU_EVMAPY
XEMU_PRE_CONFIGURE_HOOKS += XEMU_GET_SUBMODULES

$(eval $(autotools-package))
