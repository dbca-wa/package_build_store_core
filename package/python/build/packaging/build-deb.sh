#!/usr/bin/env bash

set -euxo pipefail

PYTHON_VERSION="${1:?Python version is required}"
PACKAGE_REVISION="${2:?Package revision is required}"

PACKAGE_NAME="python3.15-dbca"
SOURCE_DIRECTORY="Python-${PYTHON_VERSION}"
SOURCE_ARCHIVE="${SOURCE_DIRECTORY}.tgz"
SOURCE_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/${SOURCE_ARCHIVE}"

SCRIPT_DIRECTORY="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)"

REPOSITORY_DIRECTORY="$(
    cd "${SCRIPT_DIRECTORY}/.."
    pwd
)"

BUILD_ROOT="${REPOSITORY_DIRECTORY}/build"
SOURCE_ROOT="${BUILD_ROOT}/${SOURCE_DIRECTORY}"
DIST_DIRECTORY="${REPOSITORY_DIRECTORY}/dist"

rm -rf "${BUILD_ROOT}" "${DIST_DIRECTORY}"
mkdir -p "${BUILD_ROOT}" "${DIST_DIRECTORY}"

cd "${BUILD_ROOT}"

echo "Downloading ${SOURCE_URL}"
curl \
    --fail \
    --location \
    --retry 5 \
    --retry-delay 5 \
    --output "${SOURCE_ARCHIVE}" \
    "${SOURCE_URL}"

tar --extract --gzip --file="${SOURCE_ARCHIVE}"

cp -a "${SCRIPT_DIRECTORY}/debian" "${SOURCE_ROOT}/debian"

PACKAGE_VERSION="${PYTHON_VERSION}+${PACKAGE_REVISION}"
BUILD_DATE="$(date -R)"

sed -i \
    "s/@PACKAGE_VERSION@/${PACKAGE_VERSION}/g; s/@BUILD_DATE@/${BUILD_DATE}/g" \
    "${SOURCE_ROOT}/debian/changelog"

cd "${SOURCE_ROOT}"

dpkg-buildpackage \
    --build=binary \
    --unsigned-buildinfo \
    --unsigned-changes

find "${BUILD_ROOT}" \
    -maxdepth 1 \
    -type f \
    \( \
        -name "*.deb" \
        -o -name "*.buildinfo" \
        -o -name "*.changes" \
    \) \
    -exec cp -v {} "${DIST_DIRECTORY}/" \;

DEB_FILE="$(
    find "${DIST_DIRECTORY}" \
        -maxdepth 1 \
        -type f \
        -name "${PACKAGE_NAME}_*.deb" \
        -print \
        -quit
)"

if [ -z "${DEB_FILE}" ]; then
    echo "Debian package was not produced."
    exit 1
fi

echo "Package contents:"
dpkg-deb --contents "${DEB_FILE}"

echo "Package metadata:"
dpkg-deb --info "${DEB_FILE}"

TEST_ROOT="${BUILD_ROOT}/package-test"

rm -rf "${TEST_ROOT}"
mkdir -p "${TEST_ROOT}"

dpkg-deb --extract "${DEB_FILE}" "${TEST_ROOT}"

echo "Testing packaged Python..."

export LD_LIBRARY_PATH="${TEST_ROOT}/usr/local/lib"

"${TEST_ROOT}/usr/local/bin/python3.15" --version

"${TEST_ROOT}/usr/local/bin/python3.15" -c '
import bz2
import ctypes
import hashlib
import lzma
import readline
import sqlite3
import ssl
import sys
import uuid
import zlib

print("Python:", sys.version)
print("OpenSSL:", ssl.OPENSSL_VERSION)
print("SQLite:", sqlite3.sqlite_version)
print("zlib:", zlib.ZLIB_VERSION)
print("Python package validation passed")
'

echo "Checking Python aliases..."

test -L "${TEST_ROOT}/usr/local/bin/python"
test -L "${TEST_ROOT}/usr/local/bin/python3"

echo "python -> $(readlink "${TEST_ROOT}/usr/local/bin/python")"
echo "python3 -> $(readlink "${TEST_ROOT}/usr/local/bin/python3")"

echo "Package validation completed successfully."

sha256sum "${DIST_DIRECTORY}"/* > "${DIST_DIRECTORY}/SHA256SUMS"

echo "Built package:"
ls -lah "${DIST_DIRECTORY}"
