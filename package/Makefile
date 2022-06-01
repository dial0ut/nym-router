#
# Copyright (C) 2006-2017 OpenWrt.org
## This is the first draft of a Makefile to build Nym-gateway and later
## all other binaries for various OpenWRT targets
## Now it's hacky until Rust gets full support and gets merged into OpenWRT repos
## Use with caution :) 
## 
include $(TOPDIR)/rules.mk

PKG_NAME:=nym
PKG_VERSION:=0.12.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Hans Bricks <hans@nwbroadbandalliance.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-05-06
PKG_SOURCE_VERSION:=c3d908642afdacccda701134c7f77691abb6481b
PKG_SOURCE_URL:=https://github.com/nymtech/nym.git
PKG_MIRROR_HASH:=04ff2b5421dee0fe7749213e725e014888793b34e56814ba8b2ebe6d2f4f2762


## @grommish on Github working hard on implementing Rust into OpenWRT
## but I haven't been able to build Nym with it, but hopefully in the 
## future it will be possible. 
#PKG_BUILD_DEPENDS:=rust/host


include $(INCLUDE_DIR)/package.mk
#include $(TOPDIR)/package/feeds/custom/lang/rust/rustc_environment.mk


define Package/nym
  SECTION:=net
  CATEGORY:=Utilities
  SUBMENU:=Nym
  TITLE:=Nym Gateway
^IDEPENDS:=@!SMALL_FLASH @!LOW_MEMORY_FOOTPRINT +ca-certificates +pkg-config +build-essential
^IURL:=https://github.com/nymtech/nym
#PKG_BUILD_DEPENDS:=openssl
endef

define Package/nym/description
^Inym Rust-lang package
endef
###
## This part is to use a different toolchain for different archs.
## However, some parts are missing and I have yet to decide which
## targets are really needed and also compatible with the 
## awesome messense/rust-musl-cross container 
## -----------------------------
## NOTE: For now - only tested with aarch64-unknown-linux-musl 
ifeq ($(ARCH),mips) ## This is not supported by the container, only mips64
        CROSS_PREFIX:=mips-openwrt-linux-musl
        RUSTFLAGS:="-C linker=$(TARGET_CC_NOCACHE)"
        VOLUME:="$(BUILD_DIR)/$(PKG_VERSION)":/home/rust/src
        IMAGE:=messense/rust-musl-cross:mips64-muslabi64
else ifeq ($(ARCH),arm)
        CROSS_PREFIX:=armv7-unknown-linux-musleabihf
        RUSTFLAGS:="-C linker=$(TARGET_CC_NOCACHE)"
        VOLUME:="$(BUILD_DIR)/$(PKG_VERSION)":/home/rust/src
        IMAGE:=messense/rust-musl-cross:armv7-musleabihf
else ifeq ($(ARCH),aarch64)
        CROSS_PREFIX:=aarch64-openwrt-linux-musl
        RUSTFLAGS:="-C linker=$(TARGET_CC_NOCACHE)"
        RUST_TRIPLE:="aarch64-unknown-linux-musl"
        VOLUME:="$(BUILD_DIR)/$(PKG_VERSION)":/home/rust/src
        IMAGE:=messense/rust-musl-cross:aarch64-musl
else ifeq ($(ARCH),mips64)
        CROSS_PREFIX:=mips64-openwrt-linux
        RUSTFLAGS:="-C linker=$(TARGET_CC_NOCACHE)"
        VOLUME:="$(BUILD_DIR)/$(PKG_VERSION)":/home/rust/src
        IMAGE:=messense/rust-musl-cross:mips64-muslabi64
else ifeq ($(ARCH),mipsel)
        CROSS_PREFIX:=mipsel-openwrt-linux-musl
        RUSTFLAGS:="-C linker=$(TARGET_CC_NOCACHE)"
        VOLUME:="$(BUILD_DIR)/$(PKG_VERSION)":/home/rust/src
        IMAGE:=messense/rust-musl-cross:aarch64-musl
else ifeq ($(ARCH),x86_64)
        CROSS_PREFIX:=x86_64-openwrt-linux-musl
        RUSTFLAGS:=""
        VOLUME:="$(BUILD_DIR)/$(PKG_VERSION)":/home/rust/src
        IMAGE:=messense/rust-musl-cross:aarch64-musl
endif

####
## After Rust is fully supported by OpenWRT or Althea then
## this will be the proper way to build stuff. 
## Until then - we stick to the dirtier container solution. 
##  -- OR if you have any better idea how to do this - open a PR, THX!
##
##
#define Build/Compile
#$(call RustPackage/Cargo/Update)
#$(call RustPackage/Cargo/Compile)
#endef

## THE HACKY WAY TO BUILD IT ...
## Using https://github.com/messense/rust-musl-cross 
## all credits to @messense and everyone else who contributed to all the other stuff
## 
## Also big thanks to JUSTIN from Althea with his hacky way using CROSS, which unfortunately did not work for me
## but without it I would not come up with my own solution - using the rust-musl-cross
## container to pretty much automate the whole build !
##

## Ehm...this is pretty embarassing but I will fix the path later, now it's hardcoded until... end of the week?
NYM_PATH="/home/rust/openwrt/build_dir/target-aarch64_cortex-a72_musl/$(PKG_VERSION)/target/aarch64-unknown-linux-musl/release/nym-gateway"

define Build/Compile
        (\
                cp ~/nym-router/Cargo.toml $(PKG_BUILD_DIR)/gateway && \
                cd $(PKG_BUILD_DIR) && \
                docker run -it --rm -v $(VOLUME) $(IMAGE) \
                cargo build --release --target $(RUST_TRIPLE) --bin nym-gateway --features=vendored-openssl\
        )
endef
        #$(STRIP) $(NYM_PATH)


## Will leave this part here until I sort out the stupid path issues after 
## finishing the compiling ... too tired and lazy to fix that after this long battle
## I ran `make package/feeds/nym/package/compile V=sc` at least a million times 
#NYM_PATH:="$(PKG_BUILD_DIR)/target/$(RUST_TRIPLE)/release/nym-gateway"


##
## JUSTIN'S WAY
define Package/nym/install
        $(INSTALL_DIR) $(1)/usr/sbin
        $(INSTALL_BIN) $(NYM_PATH) $(1)/usr/sbin/nym-gateway
        $(INSTALL_DIR) $(1)/etc/init.d
endef

$(eval $(call BuildPackage,nym))
