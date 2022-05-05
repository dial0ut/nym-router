# Pull target.mk so we can type the CPU/CPU_SUBTYPE
include $(INCLUDE_DIR)/target.mk

# Rust Environmental Vars
CONFIG_HOST_SUFFIX:=$(shell cut -d"-" -f4 <<<"$(GNU_HOST_NAME)")
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)
CARGO_HOME:=$(STAGING_DIR_HOST)
LLVM_DIR:=$(STAGING_DIR_HOST)/llvm-rust

# These RUSTFLAGS are common across all TARGETs
RUSTFLAGS = -C linker=$(TOOLCHAIN_DIR)/bin/$(TARGET_CC_NOCACHE) -C ar=$(TOOLCHAIN_DIR)/bin/$(TARGET_AR)

# Common Build Flags
RUST_BUILD_FLAGS = \
  LD_LIBRARY_PATH=$(LLVM_DIR)/lib \
  RUSTFLAGS="$(RUSTFLAGS)" \
  CARGO_HOME="$(CARGO_HOME)"

# This adds the rust environmental variables to Make calls
MAKE_FLAGS += $(RUST_BUILD_FLAGS)

# ARM Logic
ifeq ($(ARCH),arm)
  ifeq ($(CONFIG_arm_v7),y)
    RUSTC_TARGET_ARCH:=$(subst arm,armv7,$(RUSTC_TARGET_ARCH))
  endif

  ifeq ($(CONFIG_HAS_FPU),y)
    RUSTC_TARGET_ARCH:=$(RUSTC_TARGET_ARCH:muslgnueabi=muslgnueabihf)
  endif

  RUSTFLAGS += -C target-cpu=$(CPU_TYPE)

  # Have a subtype?
  ifneq ($(CPU_SUBTYPE),)
    # NEON Support
    ifneq ($(findstring neon,$(CPU_SUBTYPE)),)
      RUST_FEATURES += neon
    endif

    RUST_FEATURES += $(lastword $(subst neon,,$(subst vfpv,vfp,$(subst -,,$(CPU_SUBTYPE)))))

    ifneq ($(words $(RUST_FEATURES)),1)
      RUST_TARGET_FEATURES = $(subst $(space),$(comma),$(RUST_FEATURES))
    else
      RUST_TARGET_FEATURES = $(RUST_FEATURES)
    endif
  endif
RUSTFLAGS += -C target-feature=$(RUST_TARGET_FEATURES)
endif

define RustPackage/Cargo/Update
	cd $(PKG_BUILD_DIR) && \
	$(RUST_BUILD_FLAGS) cargo update $(1)
endef

define RustPackage/Cargo/Compile
	cd $(PKG_BUILD_DIR) && \
	  $(RUST_BUILD_FLAGS) cargo build -v --release \
	  -Z build-std --target $(RUSTC_TARGET_ARCH) $(1)
endef
