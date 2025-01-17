#!/bin/bash

# Script to install gcc for the arm-none-eabi target.
#
# Based on
# https://retroramblings.net/?p=315
# https://github.com/mist-devel/mist-board/blob/master/tools/install_arm-none-eabi-gcc.sh
# https://gitlab.cs.fau.de/-/snippets/144
# https://src.fedoraproject.org/rpms/arm-none-eabi-binutils-cs/blob/rawhide/f/arm-none-eabi-binutils-cs.spec
# https://src.fedoraproject.org/rpms/arm-none-eabi-gcc-cs/blob/rawhide/f/arm-none-eabi-gcc-cs.spec
# https://src.fedoraproject.org/rpms/arm-none-eabi-newlib/blob/rawhide/f/arm-none-eabi-newlib.spec

TARGET='arm-none-eabi'

PREFIX="/opt/mist/${TARGET}"

ARCHIVES_DIR='archives'

BINUTILS_URL='ftp://ftp.fu-berlin.de/unix/gnu/binutils/'
BINUTILS_VERSION='binutils-2.43.1'
BINUTILS_ARCHIVE="${BINUTILS_VERSION}.tar.xz"
BINUTILS_MD5='9202d02925c30969d1917e4bad5a2320'

GCC_URL='ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/'
GCC_VERSION='gcc-13.3.0'
GCC_ARCHIVE="${GCC_VERSION}.tar.xz"
GCC_MD5='726726a73eaaacad4259fe5d7e978020'

NEWLIB_URL='ftp://sourceware.org/pub/newlib/'
NEWLIB_VERSION='newlib-4.5.0.20241231'
NEWLIB_ARCHIVE="${NEWLIB_VERSION}.tar.gz"
NEWLIB_MD5='7318acc715409fdf382a643d4d2661bb'

JOBS=$(nproc)

GCC_BUILD_OPTIONS="--target="${TARGET}" --prefix="${PREFIX}" --enable-languages=c --enable-interwork --enable-multilib --with-multilib-list=rmprofile --with-newlib --disable-nls --disable-shared --disable-threads"

if [[ ! -d "${ARCHIVES_DIR}" ]]; then
    mkdir "${ARCHIVES_DIR}"
fi

if [[ ! -f "${ARCHIVES_DIR}"/"${BINUTILS_ARCHIVE}" ]]; then
    echo "Downloading ${BINUTILS_ARCHIVE} ..."
    wget -P "${ARCHIVES_DIR}" "${BINUTILS_URL}${BINUTILS_ARCHIVE}"
fi

if [[ $(md5sum -b "${ARCHIVES_DIR}"/"${BINUTILS_ARCHIVE}" | cut -d' ' -f1) != "${BINUTILS_MD5}" ]]; then
    echo "Archive is broken: ${BINUTILS_ARCHIVE}"
    exit 1
fi

if [[ ! -f "${ARCHIVES_DIR}"/"${GCC_ARCHIVE}" ]]; then
    echo "Downloading ${GCC_ARCHIVE} ..."
    wget -P "${ARCHIVES_DIR}" "${GCC_URL}${GCC_VERSION}"/"${GCC_ARCHIVE}"
fi

if [[ $(md5sum -b "${ARCHIVES_DIR}"/"${GCC_ARCHIVE}" | cut -d' ' -f1) != "${GCC_MD5}" ]]; then
    echo "Archive is broken: ${GCC_ARCHIVE}"
    exit 1
fi

if [[ ! -f "${ARCHIVES_DIR}"/"${NEWLIB_ARCHIVE}" ]]; then
    echo "Downloading ${NEWLIB_ARCHIVE} ..."
    wget -P "${ARCHIVES_DIR}" "${NEWLIB_URL}${NEWLIB_ARCHIVE}"
fi

if [[ $(md5sum -b "${ARCHIVES_DIR}"/"${NEWLIB_ARCHIVE}" | cut -d' ' -f1) != "${NEWLIB_MD5}" ]]; then
    echo "Archive is broken: ${NEWLIB_ARCHIVE}"
    exit 1
fi

# ---------------- build binutils -------------
echo "Building ${BINUTILS_VERSION}, jobs: ${JOBS}"

if [[ -d "${BINUTILS_VERSION}" ]]; then
    echo "${BINUTILS_VERSION}: cleaning up previous build ..."
    rm -rf "${BINUTILS_VERSION}" 
fi

tar xf "${ARCHIVES_DIR}"/"${BINUTILS_ARCHIVE}"
cd "${BINUTILS_VERSION}"
mkdir "${TARGET}" 
cd "${TARGET}"
../configure --target="${TARGET}" --prefix="${PREFIX}" --enable-interwork --enable-multilib --disable-nls --disable-shared --disable-threads
make -j ${JOBS}
make install
cd ../../

# ---------------- build gcc stage 1 ----------
echo "Building ${GCC_VERSION} stage 1, jobs: ${JOBS}"

if [[ -d "${GCC_VERSION}" ]]; then
    echo "${GCC_VERSION}: cleaning up previous build ..."
    rm -rf "${GCC_VERSION}"
fi

tar xf "${ARCHIVES_DIR}"/"${GCC_ARCHIVE}"

cd "${GCC_VERSION}"
mkdir "${TARGET}"
cd "${TARGET}"
../configure ${GCC_BUILD_OPTIONS} --without-headers
make -j ${JOBS} all-gcc
make install-gcc
cd ../../

# ---------------- build newlib ---------------
export PATH="${PREFIX}/bin:${PATH}"

echo "Building ${NEWLIB_VERSION}, jobs: ${JOBS}"

if [[ -d "${NEWLIB_VERSION}" ]]; then
    echo "${NEWLIB_VERSION}: cleaning up previous build ..."
    rm -rf "${NEWLIB_VERSION}"
fi

tar xf "${ARCHIVES_DIR}"/"${NEWLIB_ARCHIVE}"

cd "${NEWLIB_VERSION}"

mkdir "${TARGET}"
cd "${TARGET}"
../configure --target="${TARGET}" --prefix="${PREFIX}" --enable-multilib --enable-newlib-io-long-long --enable-newlib-register-fini --enable-newlib-retargetable-locking --disable-newlib-supplied-syscalls --disable-nls --disable-libssp --with-float=soft
make -j ${JOBS}
make install
cd ../../

# ---------------- build gcc stage 2 ----------
echo "Building ${GCC_VERSION} stage 2, jobs: ${JOBS}"

cd "${GCC_VERSION}"
rm -rf "${TARGET}"
mkdir "${TARGET}"
cd "${TARGET}"
../configure ${GCC_BUILD_OPTIONS} --with-headers=yes
make -j ${JOBS}
make install
cd ../../

exit 0
