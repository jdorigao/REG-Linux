# Define the SHELL to ensure consistency and expected behavior.
# -e: exits immediately if a command fails.
# -o pipefail: a pipeline's exit status is that of the last command to fail.
SHELL := /bin/bash -eo pipefail

# --- Project Settings ---
# Use $(CURDIR) or a reference to the Makefile itself for more robustness.
# $(shell pwd) can be problematic if make is called from a subdirectory.
PROJECT_DIR		:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Variables with `?=` can be overridden from the command line.
DL_DIR		?= $(PROJECT_DIR)/dl
OUTPUT_DIR	?= $(PROJECT_DIR)/output
CCACHE_DIR	?= $(PROJECT_DIR)/buildroot-ccache
LOCAL_MK	?= $(PROJECT_DIR)/reglinux.mk
DOCKER		?= docker

# --- Build Settings ---
NPROC		:= $(shell nproc)
MAKE_JLEVEL	?= $(NPROC)
# Simplified: Multiplication by 1 was redundant.
MAKE_LLEVEL	?= $(NPROC)

# Options to control the build behavior.
PARALLEL_BUILD	?= y
DEBUG_BUILD	?= y
MINI_BUILD	?= n
BATCH_MODE	?=
EXTRA_OPTS	?=
DOCKER_OPTS	?=

# Load local configuration, if it exists.
-include $(LOCAL_MK)

# --- Dynamic Definitions ---
ifeq ($(PARALLEL_BUILD), y)
	EXTRA_OPTS += BR2_PER_PACKAGE_DIRECTORIES=y
	MAKE_OPTS += -j$(MAKE_JLEVEL) -l$(MAKE_LLEVEL)
endif

ifeq ($(DEBUG_BUILD), y)
	EXTRA_OPTS += BR2_ENABLE_DEBUG=y
endif

ifeq ($(MINI_BUILD), y)
	MAKE_OPTS += MINI_BUILD=y
endif

# In non-batch mode, Docker needs an interactive terminal.
ifndef BATCH_MODE
	DOCKER_OPTS += -it
endif

DOCKER_REPO := reglinux
IMAGE_NAME  := reglinux-build
UID := $(shell id -u)
GID := $(shell id -g)

# Find all available targets based on configuration files.
TARGETS := $(sort $(patsubst $(PROJECT_DIR)/configs/reglinux-%.board,%,$(wildcard $(PROJECT_DIR)/configs/reglinux-*.board)))

# --- Main Improvement: Docker Command Centralization ---
# Define a base Docker command to avoid repetition (DRY principle).
# Includes all volume mounts, user settings, and common options.
DOCKER_RUN_BASE = $(DOCKER) run --init --rm \
	-v $(PROJECT_DIR):/build \
	-v $(DL_DIR):/build/buildroot/dl \
	-v /etc/passwd:/etc/passwd:ro \
	-v /etc/group:/etc/group:ro \
	-u $(UID):$(GID) \
	$(DOCKER_OPTS)

# Base Make command to be run inside the container.
MAKE_CMD_BASE = make $(MAKE_OPTS) O=/$* BR2_EXTERNAL=/build -C /build/buildroot

# Check if Docker is installed at the beginning.
$(if $(shell which $(DOCKER) 2>/dev/null),, $(error "$(DOCKER) not found!"))

# Function to convert string to uppercase (used in %-rsync)
# Corrected from '$1' to '$(1)' to work with $(call)
UC = $(shell echo "'$(1)'" | tr '[:lower:]' '[:upper:]')

# --- .PHONY Targets ---
# Declare targets that do not generate files with the same name. Essential for robustness.
.PHONY: all vars build-docker-image update-docker-image publish-docker-image reglinux-docker-image \
	dl-dir merge generate uart find-dl-dups remove-dl-dups
.PHONY: %-supported %-clean %-config %-build %-source %-show-build-order %-kernel \
	%-graph-depends %-graph-build %-graph-size %-shell %-ccache-stats %-cleanbuild \
	%-pkg %-webserver %-rsync %-tail %-snapshot %-rollback %-flash %-upgrade \
	%-toolchain %-find-build-dups %-remove-build-dups output-dir-% %-ccache-dir

# --- Management and Information Targets ---
vars:
	@echo "Supported targets:  $(TARGETS)"
	@echo "Project directory:  $(PROJECT_DIR)"
	@echo "Download directory: $(DL_DIR)"
	@echo "Build directory:    $(OUTPUT_DIR)"
	@echo "ccache directory:   $(CCACHE_DIR)"
	@echo "Extra options:      $(EXTRA_OPTS)"
	@echo "Docker options:     $(DOCKER_OPTS)"
	@echo "Make options:       $(MAKE_OPTS)"

# --- Docker Image Management Targets ---
build-docker-image:
	$(DOCKER) build . -t $(DOCKER_REPO)/$(IMAGE_NAME)
	@touch .ba-docker-image-available

# Sentinel file to prevent unnecessary pulls.
.ba-docker-image-available:
	@echo "Docker image not found locally, pulling from $(DOCKER_REPO)/$(IMAGE_NAME)..."
	@$(DOCKER) pull $(DOCKER_REPO)/$(IMAGE_NAME)
	@touch .ba-docker-image-available

reglinux-docker-image: merge .ba-docker-image-available

update-docker-image:
	-@rm -f .ba-docker-image-available
	@$(MAKE) reglinux-docker-image

publish-docker-image:
	@$(DOCKER) push $(DOCKER_REPO)/$(IMAGE_NAME):latest

# --- Directory Setup Targets ---
output-dir-%:
	@mkdir -p $(OUTPUT_DIR)/$*

%-ccache-dir:
	@mkdir -p $(CCACHE_DIR)/$*

dl-dir:
	@mkdir -p $(DL_DIR)

# --- Target Validation and Configuration ---
%-supported:
	$(if $(filter $*,$(TARGETS)),,$(error "$* not supported! Available targets: $(TARGETS)"))

%-config: reglinux-docker-image output-dir-%
	@$(PROJECT_DIR)/configs/createDefconfig.sh $(PROJECT_DIR)/configs/reglinux-$*
	@for opt in $(EXTRA_OPTS); do \
		echo $$opt >> $(PROJECT_DIR)/configs/reglinux-$*_defconfig ; \
	done
	$(DOCKER_RUN_BASE) -v $(OUTPUT_DIR)/$*:/$* $(DOCKER_REPO)/$(IMAGE_NAME) \
		make O=/$* BR2_EXTERNAL=/build -C /build/buildroot reglinux-$*_defconfig

# --- Build Targets (Refactored with DOCKER_RUN_BASE) ---
%-clean: reglinux-docker-image output-dir-%
	$(DOCKER_RUN_BASE) -v $(OUTPUT_DIR)/$*:/$* $(DOCKER_REPO)/$(IMAGE_NAME) \
		make O=/$* BR2_EXTERNAL=/build -C /build/buildroot clean

%-build: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) $(CMD)

%-source: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) source

%-show-build-order: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) show-build-order

%-kernel: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) -it \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) linux-menuconfig

# --- Analysis and Graph Targets ---
%-graph-depends: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) BR2_GRAPH_OUT=svg graph-depends

%-graph-build: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) BR2_GRAPH_OUT=svg graph-build

%-graph-size: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) BR2_GRAPH_OUT=svg graph-size

# --- Interaction and Debug Targets ---
%-shell: reglinux-docker-image output-dir-%
	$(if $(BATCH_MODE),$(if $(CMD),,$(error "CMD must be specified for %-shell in BATCH_MODE!")))
	$(DOCKER_RUN_BASE) -it \
		-v $(OUTPUT_DIR)/$*:/$* \
		-w /$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(CMD)

%-ccache-stats: reglinux-docker-image %-config %-ccache-dir dl-dir
	$(DOCKER_RUN_BASE) \
		-v $(OUTPUT_DIR)/$*:/$* \
		-v $(CCACHE_DIR)/$*:$(HOME)/.buildroot-ccache \
		$(DOCKER_REPO)/$(IMAGE_NAME) \
		$(MAKE_CMD_BASE) ccache-stats

%-tail: output-dir-%
	@tail -F $(OUTPUT_DIR)/$*/build/build-time.log

# --- Composite and Package Targets ---
%-cleanbuild: %-clean %-build

%-pkg:
	$(if $(PKG),,$(error "PKG not specified! Usage: make <target>-pkg PKG=<package-name>"))
	@$(MAKE) $*-build CMD=$(PKG)

# --- Deploy and Test Targets ---
%-webserver: output-dir-%
	$(if $(wildcard $(OUTPUT_DIR)/$*/images/reglinux/*),,$(error "$* not built!"))
	$(if $(shell which python3 2>/dev/null),,$(error "python3 not found!"))
	# Define the directory more clearly
	_IMG_DIR=$(OUTPUT_DIR)/$*/images/reglinux/images
	_TARGET_DIR=$(_IMG_DIR)/$*
	if [ -n "$(BOARD)" ]; then _TARGET_DIR=$(_IMG_DIR)/$(BOARD); fi
	$(if $(wildcard $(_TARGET_DIR)),,$(error "Directory not found: $(_TARGET_DIR)"))
	python3 -m http.server --directory $(_TARGET_DIR)

%-rsync: output-dir-%
	$(eval TMP_IP_VAR := $(call UC, $*)_IP)
	$(if $(shell which rsync 2>/dev/null),, $(error "rsync not found!"))
	$(if $($(TMP_IP_VAR)),,$(error "$(TMP_IP_VAR) not set in your environment or reglinux.mk!"))
	rsync -e "ssh -o 'UserKnownHostsFile /dev/null' -o StrictHostKeyChecking=no" -av $(OUTPUT_DIR)/$*/target/ root@$($(TMP_IP_VAR)):/

%-flash: %-supported
	$(if $(DEV),,$(error "DEV not specified! Usage: make <target>-flash DEV=/dev/sdX"))
	@gzip -dc $(OUTPUT_DIR)/$*/images/reglinux/images/$*/reglinux-*.img.gz | sudo dd of=$(DEV) bs=5M status=progress
	@sync

%-upgrade: %-supported
	$(if $(DEV),,$(error "DEV not specified! Usage: make <target>-upgrade DEV=/dev/sdX"))
	_MOUNT_POINT=/tmp/mount
	-@sudo umount $(_MOUNT_POINT) || true
	-@mkdir -p $(_MOUNT_POINT)
	@sudo mount $(DEV)1 $(_MOUNT_POINT)
	-@sudo rm -rf $(_MOUNT_POINT)/boot/reglinux
	@sudo tar xvf $(OUTPUT_DIR)/$*/images/reglinux/boot.tar.xz -C $(_MOUNT_POINT) --no-same-owner
	@sudo umount $(_MOUNT_POINT)
	-@rmdir $(_MOUNT_POINT)

# --- Filesystem Management Targets (BTRFS & Duplicates) ---
# These targets are powerful, but environment-specific. Adding checks.
%-snapshot: %-supported
	$(if $(shell which btrfs 2>/dev/null),, $(error "btrfs not found!"))
	@mkdir -p $(OUTPUT_DIR)/snapshots
	-@sudo btrfs subvolume delete $(OUTPUT_DIR)/snapshots/$*-toolchain || true
	@btrfs subvolume snapshot -r $(OUTPUT_DIR)/$* $(OUTPUT_DIR)/snapshots/$*-toolchain

%-rollback: %-supported
	$(if $(shell which btrfs 2>/dev/null),, $(error "btrfs not found!"))
	-@sudo btrfs subvolume delete $(OUTPUT_DIR)/$* || true
	@btrfs subvolume snapshot $(OUTPUT_DIR)/snapshots/$*-toolchain $(OUTPUT_DIR)/$*

%-toolchain: %-supported
	$(if $(shell which btrfs 2>/dev/null),, $(error "btrfs not found!"))
	-@sudo btrfs subvolume delete $(OUTPUT_DIR)/$* || true
	@btrfs subvolume create $(OUTPUT_DIR)/$*
	@$(MAKE) $*-config
	@$(MAKE) $*-build CMD=toolchain
	@$(MAKE) $*-build CMD=llvm
	@$(MAKE) $*-snapshot

# Script to find and remove older duplicate build directories.
%-find-build-dups: %-supported
	@find $(OUTPUT_DIR)/$*/build -maxdepth 1 -type d -printf '%T@ %p %f\n' | sed -r 's:\-[0-9a-f\.]+$$::' | sort -k3 -k1 | uniq -f 2 -d | cut -d' ' -f2

%-remove-build-dups: %-supported
	@echo "Searching for and removing older duplicate build directories..."
	@while true; do \
		DUP_TO_REMOVE=$$(find $(OUTPUT_DIR)/$*/build -maxdepth 1 -type d -printf '%T@ %p\n' | sed -r 's/(\s[^\s]+)\-[0-9a-f\.]+/\1/' | sort -k2,2 -k1,1n | uniq -f1 --all-repeated=separate | head -n -1 | cut -d' ' -f2); \
		if [ -z "$$DUP_TO_REMOVE" ]; then break; fi; \
		echo "Removing: $$DUP_TO_REMOVE"; \
		rm -rf $$DUP_TO_REMOVE; \
	done
	@echo "Cleanup complete."

find-dl-dups:
	@find $(DL_DIR) -maxdepth 2 -type f \( -name "*.zip" -o -name "*.tar.*" \) -printf '%T@ %p %f\n' | sed -r 's:\-[0-9a-f\.]+(\.zip|\.tar\.[2a-z]+)$$::' | sort -k3 -k1 | uniq -f 2 -d | cut -d' ' -f2

remove-dl-dups:
	@echo "Searching for and removing older duplicate downloaded archives..."
	@while true; do \
		DUP_TO_REMOVE=$$(find $(DL_DIR) -maxdepth 2 -type f \( -name "*.zip" -o -name "*.tar.*" \) -printf '%T@ %p\n' | sed -r 's/(\s[^\s]+)\-[0-9a-f\.]+(\.zip|\.tar\.[a-z0-9]+)/\1/' | sort -k2,2 -k1,1n | uniq -f1 --all-repeated=separate | head -n -1 | cut -d' ' -f2); \
		if [ -z "$$DUP_TO_REMOVE" ]; then break; fi; \
		echo "Removing: $$DUP_TO_REMOVE"; \
		rm -rf $$DUP_TO_REMOVE; \
	done
	@echo "Cleanup complete."

# --- Scripts and Miscellaneous Targets ---
uart:
	$(if $(shell which picocom 2>/dev/null),,$(error "picocom not found!"))
	$(if $(SERIAL_DEV),,$(error "SERIAL_DEV not specified!"))
	$(if $(SERIAL_BAUDRATE),,$(error "SERIAL_BAUDRATE not specified!"))
	$(if $(wildcard $(SERIAL_DEV)),,$(error "$(SERIAL_DEV) not available!"))
	@picocom $(SERIAL_DEV) -b $(SERIAL_BAUDRATE)

merge:
	CUSTOM_DIR=$(PWD)/custom BUILDROOT_DIR=$(PWD)/buildroot $(PWD)/scripts/linux/mergeToBR.sh

generate:
	CUSTOM_DIR=$(PWD)/custom BUILDROOT_DIR=$(PWD)/buildroot $(PWD)/scripts/linux/generateCustom.sh
