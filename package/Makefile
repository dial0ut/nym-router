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

PKG_NAME:=nym
PKG_VERSION:=0.12.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Hans Bricks <hans@nwbroadbandalliance.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-05-06
PKG_SOURCE_VERSION:=skip
PKG_SOURCE_URL:=https://github.com/nymtech/nym.git
PKG_MIRROR_HASH:=skip

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/package/feeds/packages/rust/rustc_environment.mk

define Build/Compile
$(call RustPackage/Cargo/Update)
$(call RustPackage/Cargo/Compile)
endef

define Package/nym
^ITITLE:=nym
^ISECTION:=testing
^ICATEGORY:=Testing
^IDEPENDS:=@!SMALL_FLASH @!LOW_MEMORY_FOOTPRINT
^IURL:=https://github.com/nymtech/nym
endef

define Package/nym/description
^Inym Rust-lang package
endef

define Package/nym/install
$(INSTALL_DIR) $(1)/bin
$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/nym $(1)/bin/nym
endef
$(eval $(call BuildPackage,nym))
