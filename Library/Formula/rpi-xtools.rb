class RpiXtools < Formula
  desc "Cross-compiler toolchain for Raspberry Pi."
  homepage "http://n10k.com"

  # TODO: a more sophisticated version string?
  version "201510201411"
  # TODO: no actual archive for this Formula; download something small and static.
  url "http://brew.sh"
  sha256 "483957e091129c9cfacd3ccb19ddb143acbcaaf8abdfd081e070dd07a6259b86"
  keg_only "Add this toolchain to your $PATH only as needed."

  # use ggrep and gmake for maximum compatibility
  depends_on "crosstool-ng" => [:build, "with-grep", "with-make"]

  # grab most of crosstool-ng's deps as they're needed on $PATH for its runtime
  depends_on "gnu-sed" => :build
  depends_on "coreutils" => :build
  depends_on "wget" => :build
  depends_on "xz" => :build
  depends_on "gawk" => :build
  depends_on "homebrew/dupes/grep" => :build
  depends_on "homebrew/dupes/make" => :build

  # need gettext, otherwise we suffer while "Installing C library headers &
  # start files" from "fatal error: 'libintl.h' file not found"
  # also means we need to include gettext LDFLAGS flags
  # see https://gcc.gnu.org/ml/gcc-help/2014-09/msg00029.html
  # and https://sourceware.org/ml/crossgcc/2014-10/msg00004.html
  depends_on "gettext" => :build

  # automation around the process described at
  # http://www.jaredwolff.com/blog/cross-compiling-on-mac-osx-for-raspberry-pi/
  # http://www.benmont.com/tech/crosscompiler.html
  def install

    workdir = ''

    ##
    # create a case-sensitive workspace and attach
    #

    args = %W[create -type SPARSE -fs JHFS+X -size 5g -volname #{name}-#{version} #{name}-#{version}]
    system "hdiutil", *args
    args = %W[attach #{name}-#{version}.sparseimage -mountpoint ./workspace]
    system "hdiutil", *args

    begin
      chdir("./workspace", :verbose => true) do
        workdir = pwd

        ##
        # construct our .config file
        #

        # start with the defaults
        # TODO: we're bringing our own config -- is this necissary?
        system "ct-ng", "arm-unknown-linux-gnueabi"

        # Pathname#write refuses to overwrite existing file
        (buildpath/"workspace/.config").delete
        # start with config from Jared Wolff
        # http://www.jaredwolff.com/toolchains/rpi-xtools-config-201302071302.zip
        #
        # modified by formula maintainer with more recent config options and
        # turned into a template for string substitution, used later
        (buildpath/"workspace/.config").write <<-EOS
#
# Automatically generated make config: don't edit
# crosstool-NG 1.21.0 Configuration
# Tue Oct 20 14:11:22 2015
#
CT_CONFIGURE_has_xz=y
CT_CONFIGURE_has_cvs=y
CT_CONFIGURE_has_svn=y
CT_MODULES=y

#
# Paths and misc options
#

#
# crosstool-NG behavior
#
CT_OBSOLETE=y
CT_EXPERIMENTAL=y
# CT_EXPERIMENTAL_PATCHES is not set
# CT_ALLOW_BUILD_AS_ROOT is not set
# CT_DEBUG_CT is not set

#
# Paths
#
CT_LOCAL_TARBALLS_DIR="%HOMEBREW_CACHE%"
CT_SAVE_TARBALLS=y
CT_CUSTOM_LOCATION_ROOT_DIR=""
CT_WORK_DIR="%workdir%/.build"
CT_PREFIX_DIR="%workdir%/${CT_TARGET}"
CT_INSTALL_DIR="${CT_PREFIX_DIR}"
CT_RM_RF_PREFIX_DIR=y
# CT_REMOVE_DOCS is not set
# CT_BUILD_MANUALS is not set
CT_INSTALL_DIR_RO=n
CT_STRIP_ALL_TOOLCHAIN_EXECUTABLES=y

#
# Downloading
#
# CT_FORBID_DOWNLOAD is not set
# CT_FORCE_DOWNLOAD is not set
CT_CONNECT_TIMEOUT=10
# CT_ONLY_DOWNLOAD is not set
# CT_USE_MIRROR is not set

#
# Extracting
#
# CT_FORCE_EXTRACT is not set
CT_OVERIDE_CONFIG_GUESS_SUB=y
# CT_ONLY_EXTRACT is not set
CT_PATCH_BUNDLED=y
# CT_PATCH_LOCAL is not set
# CT_PATCH_BUNDLED_LOCAL is not set
# CT_PATCH_LOCAL_BUNDLED is not set
# CT_PATCH_BUNDLED_FALLBACK_LOCAL is not set
# CT_PATCH_LOCAL_FALLBACK_BUNDLED is not set
# CT_PATCH_NONE is not set
CT_PATCH_ORDER="bundled"

#
# Build behavior
#
CT_PARALLEL_JOBS=%make_jobs%
CT_LOAD=""
CT_USE_PIPES=y
CT_EXTRA_CFLAGS_FOR_BUILD="-I%gettext_opt_include%"
CT_EXTRA_LDFLAGS_FOR_BUILD="-L%gettext_opt_lib% -lintl"
CT_EXTRA_CFLAGS_FOR_HOST=""
CT_EXTRA_LDFLAGS_FOR_HOST=""
# CT_CONFIG_SHELL_SH is not set
# CT_CONFIG_SHELL_ASH is not set
CT_CONFIG_SHELL_BASH=y
# CT_CONFIG_SHELL_CUSTOM is not set
CT_CONFIG_SHELL="${bash}"

#
# Logging
#
# CT_LOG_ERROR is not set
# CT_LOG_WARN is not set
# CT_LOG_INFO is not set
CT_LOG_EXTRA=y
# CT_LOG_ALL is not set
# CT_LOG_DEBUG is not set
CT_LOG_LEVEL_MAX="EXTRA"
# CT_LOG_SEE_TOOLS_WARN is not set
CT_LOG_PROGRESS_BAR=y
CT_LOG_TO_FILE=y
CT_LOG_FILE_COMPRESS=y

#
# Target options
#
CT_ARCH="arm"
CT_ARCH_SUPPORTS_BOTH_MMU=y
CT_ARCH_SUPPORTS_BOTH_ENDIAN=y
CT_ARCH_SUPPORTS_32=y
CT_ARCH_SUPPORTS_64=y
CT_ARCH_SUPPORTS_WITH_ARCH=y
CT_ARCH_SUPPORTS_WITH_CPU=y
CT_ARCH_SUPPORTS_WITH_TUNE=y
CT_ARCH_SUPPORTS_WITH_FLOAT=y
CT_ARCH_SUPPORTS_WITH_FPU=y
CT_ARCH_SUPPORTS_SOFTFP=y
CT_ARCH_DEFAULT_HAS_MMU=y
CT_ARCH_DEFAULT_LE=y
CT_ARCH_DEFAULT_32=y
CT_ARCH_ARCH=""
CT_ARCH_CPU=""
CT_ARCH_TUNE=""
CT_ARCH_FPU=""
# CT_ARCH_BE is not set
CT_ARCH_LE=y
CT_ARCH_32=y
# CT_ARCH_64 is not set
CT_ARCH_BITNESS=32
# CT_ARCH_FLOAT_HW is not set
CT_ARCH_FLOAT_SW=y
CT_TARGET_CFLAGS=""
CT_TARGET_LDFLAGS=""
# CT_ARCH_alpha is not set
CT_ARCH_arm=y
# CT_ARCH_avr32 is not set
# CT_ARCH_blackfin is not set
# CT_ARCH_m68k is not set
# CT_ARCH_microblaze is not set
# CT_ARCH_mips is not set
# CT_ARCH_nios2 is not set
# CT_ARCH_powerpc is not set
# CT_ARCH_s390 is not set
# CT_ARCH_sh is not set
# CT_ARCH_sparc is not set
# CT_ARCH_x86 is not set
CT_ARCH_alpha_AVAILABLE=y
CT_ARCH_arm_AVAILABLE=y
CT_ARCH_avr32_AVAILABLE=y
CT_ARCH_blackfin_AVAILABLE=y
CT_ARCH_m68k_AVAILABLE=y
CT_ARCH_microblaze_AVAILABLE=y
CT_ARCH_mips_AVAILABLE=y
CT_ARCH_nios2_AVAILABLE=y
CT_ARCH_powerpc_AVAILABLE=y
CT_ARCH_s390_AVAILABLE=y
CT_ARCH_sh_AVAILABLE=y
CT_ARCH_sparc_AVAILABLE=y
CT_ARCH_x86_AVAILABLE=y
CT_ARCH_SUFFIX=""

#
# Generic target options
#
# CT_MULTILIB is not set
CT_ARCH_USE_MMU=y
CT_ARCH_ENDIAN="little"

#
# Target optimisations
#
# CT_ARCH_FLOAT_AUTO is not set
# CT_ARCH_FLOAT_SOFTFP is not set
CT_ARCH_FLOAT="soft"

#
# arm other options
#
CT_ARCH_ARM_MODE="arm"
CT_ARCH_ARM_MODE_ARM=y
# CT_ARCH_ARM_MODE_THUMB is not set
# CT_ARCH_ARM_INTERWORKING is not set
CT_ARCH_ARM_EABI=y

#
# Toolchain options
#

#
# General toolchain options
#
CT_USE_SYSROOT=y
CT_SYSROOT_NAME="sysroot"
CT_SYSROOT_DIR_PREFIX=""
# CT_STATIC_TOOLCHAIN is not set
CT_TOOLCHAIN_PKGVERSION="%toolchain_pkgversion%"
CT_TOOLCHAIN_BUGURL="https://github.com/Homebrew/homebrew/issues"

#
# Tuple completion and aliasing
#
CT_TARGET_VENDOR="none"
CT_TARGET_ALIAS_SED_EXPR=""
CT_TARGET_ALIAS=""

#
# Toolchain type
#
# CT_NATIVE is not set
CT_CROSS=y
# CT_CROSS_NATIVE is not set
# CT_CANADIAN is not set
CT_TOOLCHAIN_TYPE="cross"

#
# Build system
#
CT_BUILD=""
CT_BUILD_PREFIX=""
CT_BUILD_SUFFIX=""

#
# Misc options
#
# CT_TOOLCHAIN_ENABLE_NLS is not set

#
# Operating System
#
CT_KERNEL_SUPPORTS_SHARED_LIBS=y
CT_KERNEL="linux"
CT_KERNEL_VERSION="3.10.79"
# CT_KERNEL_bare_metal is not set
CT_KERNEL_linux=y
CT_KERNEL_bare_metal_AVAILABLE=y
CT_KERNEL_linux_AVAILABLE=y
# CT_KERNEL_LINUX_USE_CUSTOM_HEADERS is not set
# CT_KERNEL_V_4_0 is not set
# CT_KERNEL_V_3_19 is not set
# CT_KERNEL_V_3_18 is not set
# CT_KERNEL_V_3_14 is not set
# CT_KERNEL_V_3_12 is not set
CT_KERNEL_V_3_10=y
# CT_KERNEL_V_3_4 is not set
# CT_KERNEL_V_3_2 is not set
# CT_KERNEL_V_2_6_32 is not set
# CT_KERNEL_LINUX_CUSTOM is not set
CT_KERNEL_windows_AVAILABLE=y

#
# Common kernel options
#
CT_SHARED_LIBS=y

#
# linux other options
#
CT_KERNEL_LINUX_VERBOSITY_0=y
# CT_KERNEL_LINUX_VERBOSITY_1 is not set
# CT_KERNEL_LINUX_VERBOSITY_2 is not set
CT_KERNEL_LINUX_VERBOSE_LEVEL=0
CT_KERNEL_LINUX_INSTALL_CHECK=y

#
# Binary utilities
#
CT_ARCH_BINFMT_ELF=y
CT_BINUTILS="binutils"
CT_BINUTILS_binutils=y

#
# GNU binutils
#
CT_CC_BINUTILS_SHOW_LINARO=y
CT_BINUTILS_LINARO_V_2_25=y
# CT_BINUTILS_V_2_25 is not set
# CT_BINUTILS_LINARO_V_2_24 is not set
# CT_BINUTILS_V_2_24 is not set
# CT_BINUTILS_V_2_23_2 is not set
# CT_BINUTILS_V_2_23_1 is not set
# CT_BINUTILS_V_2_22 is not set
# CT_BINUTILS_V_2_21_53 is not set
# CT_BINUTILS_V_2_21_1a is not set
# CT_BINUTILS_V_2_20_1a is not set
# CT_BINUTILS_V_2_19_1a is not set
# CT_BINUTILS_V_2_18a is not set
# CT_BINUTILS_CUSTOM is not set
CT_BINUTILS_VERSION="linaro-2.25.0-2015.01-2"
CT_BINUTILS_2_25_or_later=y
CT_BINUTILS_2_24_or_later=y
CT_BINUTILS_2_23_or_later=y
CT_BINUTILS_2_22_or_later=y
CT_BINUTILS_2_21_or_later=y
CT_BINUTILS_2_20_or_later=y
CT_BINUTILS_2_19_or_later=y
CT_BINUTILS_2_18_or_later=y
CT_BINUTILS_HAS_HASH_STYLE=y
CT_BINUTILS_HAS_GOLD=y
CT_BINUTILS_GOLD_SUPPORTS_ARCH=y
CT_BINUTILS_HAS_PLUGINS=y
CT_BINUTILS_HAS_PKGVERSION_BUGURL=y
CT_BINUTILS_FORCE_LD_BFD=y
CT_BINUTILS_LINKER_LD=y
# CT_BINUTILS_LINKER_LD_GOLD is not set
# CT_BINUTILS_LINKER_GOLD_LD is not set
CT_BINUTILS_LINKERS_LIST="ld"
CT_BINUTILS_LINKER_DEFAULT="bfd"
# CT_BINUTILS_PLUGINS is not set
CT_BINUTILS_EXTRA_CONFIG_ARRAY=""
CT_BINUTILS_FOR_TARGET=y
CT_BINUTILS_FOR_TARGET_IBERTY=y
CT_BINUTILS_FOR_TARGET_BFD=y

#
# binutils other options
#

#
# C-library
#
CT_LIBC="glibc"
CT_LIBC_VERSION="2.21"
CT_LIBC_glibc=y
# CT_LIBC_musl is not set
# CT_LIBC_uClibc is not set
CT_LIBC_glibc_AVAILABLE=y
CT_THREADS="nptl"
CT_CC_GLIBC_SHOW_LINARO=y
CT_LIBC_GLIBC_V_2_21=y
# CT_LIBC_GLIBC_LINARO_V_2_20 is not set
# CT_LIBC_GLIBC_V_2_20 is not set
# CT_LIBC_GLIBC_V_2_19 is not set
# CT_LIBC_GLIBC_V_2_18 is not set
# CT_LIBC_GLIBC_V_2_17 is not set
# CT_LIBC_GLIBC_V_2_16_0 is not set
# CT_LIBC_GLIBC_V_2_15 is not set
# CT_LIBC_GLIBC_V_2_14_1 is not set
# CT_LIBC_GLIBC_V_2_14 is not set
# CT_LIBC_GLIBC_V_2_13 is not set
# CT_LIBC_GLIBC_V_2_12_2 is not set
# CT_LIBC_GLIBC_V_2_12_1 is not set
# CT_LIBC_GLIBC_V_2_11_1 is not set
# CT_LIBC_GLIBC_V_2_11 is not set
# CT_LIBC_GLIBC_V_2_10_1 is not set
# CT_LIBC_GLIBC_V_2_9 is not set
# CT_LIBC_GLIBC_V_2_8 is not set
# CT_LIBC_GLIBC_CUSTOM is not set
CT_LIBC_GLIBC_2_20_or_later=y
CT_LIBC_mingw_AVAILABLE=y
CT_LIBC_musl_AVAILABLE=y
CT_LIBC_newlib_AVAILABLE=y
CT_LIBC_none_AVAILABLE=y
CT_LIBC_uClibc_AVAILABLE=y
CT_LIBC_SUPPORT_THREADS_ANY=y
CT_LIBC_SUPPORT_THREADS_NATIVE=y

#
# Common C library options
#
CT_THREADS_NATIVE=y
CT_LIBC_XLDD=y

#
# glibc other options
#
# CT_LIBC_GLIBC_PORTS_EXTERNAL is not set
CT_LIBC_glibc_familly=y
CT_LIBC_GLIBC_EXTRA_CONFIG_ARRAY=""
CT_LIBC_GLIBC_CONFIGPARMS=""
CT_LIBC_GLIBC_EXTRA_CFLAGS=""
CT_LIBC_EXTRA_CC_ARGS=""
# CT_LIBC_ENABLE_FORTIFIED_BUILD is not set
# CT_LIBC_DISABLE_VERSIONING is not set
CT_LIBC_OLDEST_ABI=""
CT_LIBC_GLIBC_FORCE_UNWIND=y
CT_LIBC_ADDONS_LIST=""
# CT_LIBC_LOCALES is not set
# CT_LIBC_GLIBC_KERNEL_VERSION_NONE is not set
CT_LIBC_GLIBC_KERNEL_VERSION_AS_HEADERS=y
# CT_LIBC_GLIBC_KERNEL_VERSION_CHOSEN is not set
CT_LIBC_GLIBC_MIN_KERNEL="3.10.79"

#
# C compiler
#
CT_CC="gcc"
CT_CC_VERSION="linaro-4.7-2014.06"
CT_CC_CORE_PASSES_NEEDED=y
CT_CC_CORE_PASS_1_NEEDED=y
CT_CC_CORE_PASS_2_NEEDED=y
CT_CC_gcc=y
CT_CC_GCC_SHOW_LINARO=y
# CT_CC_V_5_1 is not set
# CT_CC_V_linaro_4_9 is not set
# CT_CC_V_4_9_2 is not set
# CT_CC_V_4_9_1 is not set
# CT_CC_V_4_9_0 is not set
# CT_CC_V_linaro_4_8 is not set
# CT_CC_V_4_8_4 is not set
# CT_CC_V_4_8_3 is not set
# CT_CC_V_4_8_2 is not set
# CT_CC_V_4_8_1 is not set
# CT_CC_V_4_8_0 is not set
CT_CC_V_linaro_4_7=y
# CT_CC_V_4_7_4 is not set
# CT_CC_V_4_7_3 is not set
# CT_CC_V_4_7_2 is not set
# CT_CC_V_4_7_1 is not set
# CT_CC_V_4_7_0 is not set
# CT_CC_V_linaro_4_6 is not set
# CT_CC_V_4_6_4 is not set
# CT_CC_V_4_6_3 is not set
# CT_CC_V_4_6_2 is not set
# CT_CC_V_4_6_1 is not set
# CT_CC_V_4_6_0 is not set
# CT_CC_V_linaro_4_5 is not set
# CT_CC_V_4_5_3 is not set
# CT_CC_V_4_5_2 is not set
# CT_CC_V_4_5_1 is not set
# CT_CC_V_4_5_0 is not set
# CT_CC_V_linaro_4_4 is not set
# CT_CC_V_4_4_7 is not set
# CT_CC_V_4_4_6 is not set
# CT_CC_V_4_4_5 is not set
# CT_CC_V_4_4_4 is not set
# CT_CC_V_4_4_3 is not set
# CT_CC_V_4_4_2 is not set
# CT_CC_V_4_4_1 is not set
# CT_CC_V_4_4_0 is not set
# CT_CC_V_4_3_6 is not set
# CT_CC_V_4_3_5 is not set
# CT_CC_V_4_3_4 is not set
# CT_CC_V_4_3_3 is not set
# CT_CC_V_4_3_2 is not set
# CT_CC_V_4_3_1 is not set
# CT_CC_V_4_2_4 is not set
# CT_CC_V_4_2_2 is not set
# CT_CC_V_4_1_2 is not set
# CT_CC_V_4_0_4 is not set
# CT_CC_V_3_4_6 is not set
# CT_CC_CUSTOM is not set
CT_CC_GCC_4_2_or_later=y
CT_CC_GCC_4_3_or_later=y
CT_CC_GCC_4_4_or_later=y
CT_CC_GCC_4_5_or_later=y
CT_CC_GCC_4_6_or_later=y
CT_CC_GCC_4_7=y
CT_CC_GCC_4_7_or_later=y
CT_CC_GCC_HAS_GRAPHITE=y
# CT_CC_GCC_USE_GRAPHITE is not set
CT_CC_GCC_HAS_LTO=y
# CT_CC_GCC_USE_LTO is not set
CT_CC_GCC_HAS_PKGVERSION_BUGURL=y
CT_CC_GCC_HAS_BUILD_ID=y
CT_CC_GCC_HAS_LNK_HASH_STYLE=y
CT_CC_GCC_USE_GMP_MPFR=y
CT_CC_GCC_USE_MPC=y
CT_CC_GCC_HAS_LIBQUADMATH=y
# CT_CC_LANG_FORTRAN is not set
CT_CC_SUPPORT_CXX=y
CT_CC_SUPPORT_FORTRAN=y
CT_CC_SUPPORT_JAVA=y
CT_CC_SUPPORT_ADA=y
CT_CC_SUPPORT_OBJC=y
CT_CC_SUPPORT_OBJCXX=y

#
# Additional supported languages:
#
CT_CC_LANG_CXX=y
# CT_CC_LANG_JAVA is not set
# CT_CC_LANG_ADA is not set
# CT_CC_LANG_OBJC is not set
# CT_CC_LANG_OBJCXX is not set
CT_CC_LANG_OTHERS=""

#
# gcc other options
#
CT_CC_ENABLE_CXX_FLAGS=""
CT_CC_CORE_EXTRA_CONFIG_ARRAY=""
CT_CC_EXTRA_CONFIG_ARRAY=""
# CT_CC_STATIC_LIBSTDCXX is not set
# CT_CC_GCC_SYSTEM_ZLIB is not set

#
# Optimisation features
#

#
# Settings for libraries running on target
#
CT_CC_GCC_ENABLE_TARGET_OPTSPACE=y
# CT_CC_GCC_LIBMUDFLAP is not set
# CT_CC_GCC_LIBGOMP is not set
# CT_CC_GCC_LIBSSP is not set
# CT_CC_GCC_LIBQUADMATH is not set

#
# Misc. obscure options.
#
CT_CC_CXA_ATEXIT=y
# CT_CC_GCC_DISABLE_PCH is not set
# CT_CC_GCC_SJLJ_EXCEPTIONS is not set
CT_CC_GCC_LDBL_128=m
# CT_CC_GCC_BUILD_ID is not set
CT_CC_GCC_LNK_HASH_STYLE_DEFAULT=y
# CT_CC_GCC_LNK_HASH_STYLE_SYSV is not set
# CT_CC_GCC_LNK_HASH_STYLE_GNU is not set
# CT_CC_GCC_LNK_HASH_STYLE_BOTH is not set
CT_CC_GCC_LNK_HASH_STYLE=""
CT_CC_GCC_DEC_FLOAT_AUTO=y
# CT_CC_GCC_DEC_FLOAT_BID is not set
# CT_CC_GCC_DEC_FLOAT_DPD is not set
# CT_CC_GCC_DEC_FLOATS_NO is not set

#
# Debug facilities
#
# CT_DEBUG_dmalloc is not set
# CT_DEBUG_duma is not set
# CT_DEBUG_gdb is not set
# CT_DEBUG_ltrace is not set
# CT_DEBUG_strace is not set

#
# Companion libraries
#
CT_COMPLIBS_NEEDED=y
CT_GMP_NEEDED=y
CT_MPFR_NEEDED=y
CT_MPC_NEEDED=y
CT_COMPLIBS=y
CT_GMP=y
CT_MPFR=y
CT_MPC=y
# CT_GMP_V_6_0_0 is not set
# CT_GMP_V_5_1_3 is not set
CT_GMP_V_5_1_1=y
# CT_GMP_V_5_0_2 is not set
# CT_GMP_V_5_0_1 is not set
# CT_GMP_V_4_3_2 is not set
# CT_GMP_V_4_3_1 is not set
# CT_GMP_V_4_3_0 is not set
CT_GMP_5_0_2_or_later=y
CT_GMP_VERSION="5.1.1"
CT_MPFR_V_3_1_2=y
# CT_MPFR_V_3_1_0 is not set
# CT_MPFR_V_3_0_1 is not set
# CT_MPFR_V_3_0_0 is not set
# CT_MPFR_V_2_4_2 is not set
# CT_MPFR_V_2_4_1 is not set
# CT_MPFR_V_2_4_0 is not set
CT_MPFR_VERSION="3.1.2"
# CT_MPC_V_1_0_2 is not set
CT_MPC_V_1_0_1=y
# CT_MPC_V_1_0 is not set
# CT_MPC_V_0_9 is not set
# CT_MPC_V_0_8_2 is not set
# CT_MPC_V_0_8_1 is not set
# CT_MPC_V_0_7 is not set
CT_MPC_VERSION="1.0.1"

#
# Companion libraries common options
#
# CT_COMPLIBS_CHECK is not set

#
# Companion tools
#

#
# READ HELP before you say 'Y' below !!!
#
# CT_COMP_TOOLS is not set

#
# Test suite
#
# CT_TEST_SUITE_GCC is not set
EOS

        ##
        # replace our template parameters
        #

        # retain downloaded files in homebrew cache
        inreplace ".config", "%HOMEBREW_CACHE%", HOMEBREW_CACHE
        # use workdir as workspace root. also used as prefix. This is okay
        # because toolchains are relocatable, according to
        # https://sourceware.org/ml/crossgcc/2013-06/msg00027.html
        inreplace ".config", "%workdir%", workdir
        # sane make parallelism
        inreplace ".config", "%make_jobs%", "#{ENV.make_jobs}"
        # add gettext include path and linker options
        inreplace ".config", "%gettext_opt_include%", Formula["gettext"].opt_include
        inreplace ".config", "%gettext_opt_lib%", Formula["gettext"].opt_lib
        # whoami
        inreplace ".config", "%toolchain_pkgversion%",
                  "Homebrew #{name} #{pkg_version} #{build.used_options*" "}".
                    strip
        # TODO: assert no %var% remains in .config

        # update with defaults in case crosstool-ng updated since our template
        system "yes '' | ct-ng oldconfig"

        ##
        # finally, build and install
        #

        # need to up the ulimit from osx's default of 256
        system "ulimit -n 1024 && ct-ng build"
        prefix.install Dir["arm-none-linux-gnueabi/*"]
      end
    ensure
      # be sure we don't leave the volume laying around
      system "hdiutil", "detach", workdir
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      int main()
      {
        printf("Hello, world!\n");
        return 0;
      }
    EOS
    system "#{prefix}/bin/arm-none-linux-gnueabi-gcc --version"
    system "#{prefix}/bin/arm-none-linux-gnueabi-gcc -o #{testpath}/test #{testpath}/test.c"
    system "/usr/bin/env file #{testpath}/test"
  end
end
