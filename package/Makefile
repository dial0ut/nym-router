#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

#TODO
#
# * uClibcpp not supported, performance +100x slower. libstdcpp is being used. https://bugs.busybox.net/show_bug.cgi?id=2545
# * liblua is still not recognized/blindly accepted. Impossible to compile with support
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nym-gateway
PKG_VERSION:=0.12.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Hans Bricks <hans@nwbroadbandalliance.org>

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nymtech/nym.git;
#PKG_HASH:=fcfa5a0e42099e12e4bf7a68ebe6fde05553383a682e816a7ec9256ab4773faa
PKG_LICENSE:=GPL-3.0 License
PKG_LICENSE_FILES:=COPYING
#PKG_CPE_ID:=cpe:/a:nym-router:nym-router
PKG_MIRROR := skip

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=${HOME}/nym-gateway-builder/openwrt/nym
#cross build --bins nym-gateway --release --target aarch64-unknown-linux-musl  --features vendored-openssl
CARGO_HOME := $(STAGING_DIR_HOST)
TARGET_CONFIGURE_OPTS += CARGO_HOME="$(STAGING_DIR_HOST)"

include $(INCLUDE_DIR)/package.mk

CONFIG_HOST_SUFFIX:=$(shell cut -d"-" -f4 <<<"$(GNU_HOST_NAME)")
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)

CONFIGURE_VARS += \
        CARGO_HOME="$(CARGO_HOME)" \
        ac_cv_path_CARGO="$(STAGING_DIR_HOST)/bin/cargo" \
        ac_cv_path_RUSTC="$(STAGING_DIR_HOST)/bin/rustc" \
        RUSTFLAGS="-C linker=$(TARGET_CC_NOCACHE) -C ar=$(TARGET_AR)"

CONFIGURE_ARGS += \
  	--host=$(REAL_GNU_TARGET_NAME)

include $(INCLUDE_DIR)/package.mk
#include ../../lang/python/python3-package.mk

#nym-router_DEPENDS:=+libpcap +libstdcpp +zlib +libpcre +pkg-config +build-essential +libssl-dev 
#NCAT_DEPENDS:=+libpcap
#NPING_DEPENDS:=+libpcap +libpthread +libstdcpp

define Package/nym-gateway
  SUBMENU:=nym-openwrt
  SECTION:=net
  CATEGORY:=Network
  URL:=https://nymtech.net
endef

CARGO_HOME := $(STAGING_DIR_HOST)/.cargo
RUSTFLAGS="-C linker=$(TARGET_CC_NOCACHE) -C ar=$(TARGET_AR)"

CONFIGURE_VARS += \
        CARGO_HOME=$(CARGO_HOME) \
        RUSTFLAGS=$(RUSTFLAGS)

define Build/Compile
	cd $(PKG_BUILD_DIR) && git checkout tags/v0.12.1 && $(TARGET_CONFIGURE_OPTS) $(CONFIGURE_VARS) cargo update && \
	$(TARGET_CONFIGURE_OPTS) $(CONFIGURE_VARS) \
  source $(CARGO_HOME)/env && \
	CARGO_HOME=$(CARGO_HOME) \
	RUSTUP_HOME=$(RUSTUP_HOME) \
	TARGET_CC=$(TARGET_CC_NOCACHE) \
	TARGET_CXX=$(TARGET_CXX_NOCACHE) \
	PKG_CONFIG_ALLOW_CROSS=1 \
	CROSS_COMPILE=$(CROSS_PREFIX) \
	RUSTFLAGS="-C linker=$(TARGET_CC_NOCACHE) -C ar=$(TARGET_AR)" \
	RUSTC="$(CARGO_HOME)/bin/rustc" \
	$(CARGO_HOME)/bin/cargo" build --bins nym-gateway --release --target aarch64-unknown-linux-musl  --features 'vendored-openssl' --manifest-path $(PKG_BUILD_DIR)/gateway/Cargo.toml
endef

define Package/nym-gateway
  SUBMENU:=nym-openwrt
  SECTION:=net
  CATEGORY:=Network
  URL:=https://nymtech.net
endef

#define Build/Compile
#        # Setting LD_LIBRARY_PATH appears necessary in order for `rustc` to find the LLVM library
#        # if it is run indirectly by custom crate build scripts compilation steps (such as the one for cmake)
#        cd $(PKG_BUILD_DIR) && \
#          LD_LIBRARY_PATH=$(STAGING_DIR_HOST)/lib \
#          $(CONFIGURE_VARS) cargo build --release --target=$(REAL_GNU_TARGET_NAME)

#define Package/nym-router/install
#	$(INSTALL_DIR) $(1)/usr/bin
#	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nym-router $(1)/usr/bin/
#	$(INSTALL_DIR) $(1)/usr/share/nym-router
#	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/nym-router/nym-router* $(1)/usr/share/nym-router/
#endef





#CARGO_HOME := $(STAGING_DIR_HOST)/.cargo
#RUSTFLAGS="-C linker=$(TARGET_CC_NOCACHE) -C ar=$(TARGET_AR)"
#
#CONFIGURE_VARS += \
#        CARGO_HOME=$(CARGO_HOME) \
#        RUSTFLAGS=$(RUSTFLAGS)
#
#define Build/Compile
#        # Setting LD_LIBRARY_PATH appears necessary in order for `rustc` to find the LLVM library
#        # if it is run indirectly by custom crate build scripts compilation steps (such as the one for cmake)
#        cd $(PKG_BUILD_DIR) && \
#          LD_LIBRARY_PATH=$(STAGING_DIR_HOST)/lib \
#          $(CONFIGURE_VARS) cargo build --release --target=$(REAL_GNU_TARGET_NAME)
#endef

#define Package/nym-router
#        SECTION:=examples
#        CATEGORY:=Examples
#        TITLE:=Rust MQTT
#endef

define Package/nym-gateway/description
  Nym-gateway package for OpenWRT
endef

define Package/nym-gateway/install
        $(INSTALL_DIR) $(1)/usr/bin
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/target/aarch64-unknown-linux-musl/release/nym-gateway $(1)/usr/bin
endef

$(eval $(call BuildPackage,nym-gateway))
