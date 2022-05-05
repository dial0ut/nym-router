# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
include $(TOPDIR)/rules.mk

PKG_NAME:=rust
PKG_VERSION:=1.60.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rust-lang/rust.git
PKG_SOURCE_DATE:=2022-04-07
PKG_SOURCE_VERSION:=7737e0b5c4103216d6fd8cf941b7ab9bdbaace7c
PKG_MIRROR_HASH:=abf826ee61460ce7a64b87c956a88dfa157e283d5d465dd839b807d31fef4b83

PKG_BUILD_PARALLEL:=1
HOST_USE_NINJA:=1

include $(INCLUDE_DIR)/host-build.mk
#include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/package.mk

# Requires Python3 to build
HOST_BUILD_DEPENDS:=python3/host llvm-project-rustc
PKG_BUILD_DEPENDS:=rust/host

# rust environmental variables
include ./rust_environment.mk

# Use External rust-lang specific LLVM
RUST_UNINSTALL:=$(CARGO_HOME)/lib/rustlib/uninstall.sh
RUST_TMP_DIR:=$(TMP_DIR)/rust-install
RUSTC_TARGET_AVAILABLE:=$($(CARGO_HOME)/bin/rustc --print target-list \
                        --target $(RUSTC_TARGET_ARCH) | \
                        awk '$1 ~ /$(RUSTC_TARGET_ARCH)/')

# Set Configure Environmentals
HOST_CONFIGURE_OPTS += CARGO_HOME="$(CARGO_HOME)"

# The Flags are Common between HOST and TARGET
RUST_COMMON_ARGS := \
  --build=$(RUSTC_HOST_ARCH) \
  --host=$(RUSTC_HOST_ARCH) \
  --dist-compression-formats=xz \
  --enable-llvm-link-shared \
  --enable-llvm-plugins \
  --enable-missing-tools \
  --enable-ninja \
  --enable-optimize \
  --enable-optimize-llvm \
  --enable-parallel-compiler \
  --enable-sanitizers \
  --release-channel=nightly \
  --prefix=$(CARGO_HOME) \
  --bindir=$(CARGO_HOME)/bin \
  --libdir=$(CARGO_HOME)/lib \
  --sysconfdir=$(CARGO_HOME)/etc \
  --datadir=$(CARGO_HOME)/share \
  --mandir=$(CARGO_HOME)/man \
  --llvm-root=$(LLVM_DIR) \
  --set=target.$(RUSTC_TARGET_ARCH).llvm-config=$(LLVM_DIR)/bin/llvm-config

# MUSL Targets need additional flags
MUSL_ARGS = \
  --set=target.$(RUSTC_TARGET_ARCH).ar=$(TARGET_AR) \
  --set=target.$(RUSTC_TARGET_ARCH).cc=$(TARGET_CC_NOCACHE) \
  --set=target.$(RUSTC_TARGET_ARCH).cxx=$(TARGET_CXX_NOCACHE) \
  --set=target.$(RUSTC_TARGET_ARCH).linker=$(TARGET_CC_NOCACHE) \
  --set=target.$(RUSTC_TARGET_ARCH).musl-root=$(TOOLCHAIN_DIR) \
  --set=target.$(RUSTC_TARGET_ARCH).ranlib=$(TARGET_RANLIB)

##
# Because OpenWrt uses default configure flags that are not recognized
# we override the default and set our own.
#
# Rust HOST Configuration Arguments
HOST_CONFIGURE_ARGS = \
  --target=$(RUSTC_HOST_ARCH) \
  ${RUST_COMMON_ARGS}

###
# Rust TARGET Configuration Args
# Re-Use existing cargo and rustc instead of building new
CONFIGURE_ARGS = \
  --target=$(RUSTC_TARGET_ARCH) \
  --set=build.cargo=$(CARGO_HOME)/bin/cargo \
  --set=build.rustc=$(CARGO_HOME)/bin/rustc \
  ${RUST_COMMON_ARGS} \
  $(MUSL_ARGS)

define Host/Uninstall
	# Call the Uninstall script
	[ -f $(RUST_UNINSTALL) ] && \
	  $(BASH) $(RUST_UNINSTALL) || echo No Uninstall

	rm -rf $(RUST_TMP_DIR)
endef

# Installation is done via Host/Compile
define Host/Install
	true
endef

define Host/Prepare
	# Ensure rust temp directory
	[ -d $(RUST_TMP_DIR) ] || \
	  mkdir -p $(RUST_TMP_DIR)

	$(call Host/Prepare/Default)
endef

###
# Build out stage1 artifacts only, stage2 is not needed
# Only build out minimal tools required to build the tuples
define Host/Compile
	cd $(HOST_BUILD_DIR) && \
	 LD_LIBRARY_PATH=$(LLVM_DIR)/lib \
	  $(PYTHON) x.py install --config ./config.toml --stage 1 cargo \
	  library/std rustfmt src src/librustc
endef

# If the tuple is already avalable, don't rebuild
ifeq ($(RUSTC_TARGET_AVAILABLE),)
  define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	 LD_LIBRARY_PATH=$(LLVM_DIR)/lib \
	 $(PYTHON) x.py install --config ./config.toml -i --stage 1 library/std
  endef
else
  define Build/Compile
	true
  endef
endif

# Nothing will ever be installed via Build/Install
define Build/Install
	true
endef

define Package/rust
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Rust Programming Language Compiler
  URL:=https://www.rust-lang.org/
  DEPENDS:=@(aarch64||arm||mips64||mips||mipsel||x86_64) \
    +pkg-config +libunwind
endef

define Package/rust/description
  Rust is a multi-paradigm, general-purpose programming language designed for
  performance and safety, especially safe concurrency. Rust is syntactically
  similar to C++, but can guarantee memory safety by using a borrow checker
  to validate references.
endef

define Package/rust/config
	source "$(SOURCE)/Config.in"
endef

# Nothing to install for package
define Package/rust/install
	true
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rust))
