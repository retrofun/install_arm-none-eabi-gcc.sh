#!/bin/bash

# Script to install gcc as described on
# http://retroramblings.net/?p=315

TARGET='arm-none-eabi'

PREFIX="/opt/mist/${TARGET}"

ARCHIVES_DIR='archives'

BINUTILS_URL='ftp://ftp.fu-berlin.de/unix/gnu/binutils/'
BINUTILS_VERSION='binutils-2.42'
BINUTILS_ARCHIVE="${BINUTILS_VERSION}.tar.xz"
BINUTILS_MD5='a075178a9646551379bfb64040487715'

GCC_URL='ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/'
GCC_VERSION='gcc-13.3.0'
GCC_ARCHIVE="${GCC_VERSION}.tar.xz"
GCC_MD5='726726a73eaaacad4259fe5d7e978020'

NEWLIB_URL='ftp://sourceware.org/pub/newlib/'
NEWLIB_VERSION='newlib-4.2.0.20211231'
NEWLIB_ARCHIVE="${NEWLIB_VERSION}.tar.gz"
NEWLIB_MD5='f7289e3185ca8022d9c63c5351bf5439'

JOBS=$(nproc)

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

# ------------------------ build binutils ------------------
echo "Building ${BINUTILS_VERSION}, jobs: ${JOBS}"

if [[ -d "${BINUTILS_VERSION}" ]]; then
    echo "Cleaning up previous build ..."
    rm -rf "${BINUTILS_VERSION}"
fi

tar xf "${ARCHIVES_DIR}"/"${BINUTILS_ARCHIVE}"
cd "${BINUTILS_VERSION}"
mkdir "${TARGET}"
cd "${TARGET}"
../configure --target="${TARGET}" --prefix="${PREFIX}"
make -j ${JOBS}
make install
cd ../../

# ------------------------ build gcc ------------------
export PATH="${PREFIX}/bin:${PATH}"

echo "Building ${GCC_VERSION}, jobs: ${JOBS}"

if [[ -d "${GCC_VERSION}" ]]; then
    echo "Cleaning up previous build ..."
    rm -rf "${GCC_VERSION}"
fi

tar xf "${ARCHIVES_DIR}"/"${GCC_ARCHIVE}"

if [[ -d "${NEWLIB_VERSION}" ]]; then
    echo "Cleaning up previous build ..."
    rm -rf "${NEWLIB_VERSION}"
fi

tar xf "${ARCHIVES_DIR}"/"${NEWLIB_ARCHIVE}"

cd "${GCC_VERSION}"
ln -s ../"${NEWLIB_VERSION}"/newlib .
mkdir "${TARGET}"
cd "${TARGET}"
../configure --target="${TARGET}" --prefix="${PREFIX}" --enable-languages=c --with-newlib --enable-newlib-io-long-long
make -j ${JOBS}
make install
cd ../../

exit 0
