# Toolchain and kernel
# CROSS_COMPILE :=
# # Linux Kernel header
# KERNEL := /lib/modules/$(shell uname -r)/build
# # Architecture
# ARCH := $(shell uname -m)

# target=spi or target=sdio

# CROSS_COMPILE := aarch64-linux-gnu-
# KERNEL := ~/workspace/rpi/linux-rpi-6.12.25_20250428 
# ARCH := arm64


# ARCH := mips
# OPENWRT_DIR     := ~/workspace/openwrt-linkit
# OPENWRT_TARGET_ARCH     := target-mipsel_24kc_musl
# OPENWRT_TARGET          := linux-ramips_mt76x8
# OPENWRT_KERNEL_VER      := linux-6.6.95
# OPENWRT_TOOLCHAIN_VER   := toolchain-mipsel_24kc_gcc-14.3.0_musl
# OPENWRT_TOOLCHAIN_BIN   := mipsel-openwrt-linux-musl-
# OPENWRT_TOOLCHAIN_ELF	  := elf32ltsmip

ARCH := arm64
OPENWRT_DIR     := ~/workspace/openwrt-rpi
OPENWRT_TARGET_ARCH     := target-aarch64_cortex-a72_musl
OPENWRT_TARGET          := linux-bcm27xx_bcm2711
OPENWRT_KERNEL_VER      := linux-6.12.35
OPENWRT_TOOLCHAIN_VER   := toolchain-aarch64_cortex-a72_gcc-14.3.0_musl
OPENWRT_TOOLCHAIN_BIN   := aarch64-openwrt-linux-musl-
OPENWRT_TOOLCHAIN_ELF	:= aarch64elf

BUILD_TARGET_DIR := ${OPENWRT_DIR}/build_dir/${OPENWRT_TARGET_ARCH}/${OPENWRT_TARGET}
KERNEL := ${BUILD_TARGET_DIR}/${OPENWRT_KERNEL_VER}
SYMBOL_DIR := ${BUILD_TARGET_DIR}/symvers
CROSS_COMPILE := ${OPENWRT_DIR}/staging_dir/${OPENWRT_TOOLCHAIN_VER}/bin/${OPENWRT_TOOLCHAIN_BIN}
STAGING_DIR := ${OPENWRT_DIR}/staging_dir/${OPENWRT_TARGET_ARCH}
KBUILD_EXTRA_SYMBOLS := ${SYMBOL_DIR}/mac80211.symvers


# Normalize ARCH
ifeq ($(ARCH), x86_64)
    ARCH := x86
endif
ifeq ($(ARCH), aarch64)
    ARCH := arm64
endif

# Module name (default: sdio)
target ?= sdio
MODULE_NAME := esp32_$(target)
MAPFILE := $(MODULE_NAME).map

# Debug and AP support
CONFIG_DEBUG_LOGS ?= y
ifeq ($(CONFIG_AP_SUPPORT), y)
    EXTRA_CFLAGS += -DCONFIG_AP_MODE
endif

# Source and include paths
PWD := $(shell pwd)
ccflags-y += -I$(src) -I$(src)/include -I$(CURDIR) -I$(CURDIR)/include
EXTRA_CFLAGS += -I$(M) -I$(M)/include

# Interface-specific sources
ifeq ($(target), sdio)
    ccflags-y += -I$(src)/sdio -I$(CURDIR)/sdio
    EXTRA_CFLAGS += -I$(M)/sdio
    module_objects += sdio/esp_sdio.o sdio/esp_sdio_api.o
endif

ifeq ($(target), spi)
    ccflags-y += -I$(src)/spi -I$(CURDIR)/spi
    EXTRA_CFLAGS += -I$(M)/spi
    module_objects += spi/esp_spi.o
endif

# Common source files
module_objects += esp_bt.o main.o esp_cmd.o esp_utils.o esp_cfg80211.o esp_stats.o esp_debugfs.o esp_log.o
CFLAGS_esp_log.o = -DDEBUG

# Module build rules
obj-m := $(MODULE_NAME).o
$(MODULE_NAME)-y := $(module_objects)

# Default build target with MAP file generation
all: clean modules map
# all: clean modules

modules:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
		STAGING_DIR=$(STAGING_DIR) KBUILD_EXTRA_SYMBOLS=$(KBUILD_EXTRA_SYMBOLS) \
		-C $(KERNEL) M=$(PWD) modules

# Link manually for MAP file
map:
	$(CROSS_COMPILE)ld -m $(OPENWRT_TOOLCHAIN_ELF) -r --cref --Map=$(MAPFILE) -o $(MODULE_NAME).ko.tmp \
		--whole-archive $(patsubst %.o, %.o, $(module_objects)) \
		--no-whole-archive

clean:
	rm -rf *.o */*.o *.ko *.mod.c *.symvers *.order .*.cmd .tmp_versions *.map *.ko.tmp
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNEL) M=$(PWD) clean

check:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNEL) M=$(PWD) $(module_objects)
