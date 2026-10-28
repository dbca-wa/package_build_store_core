#!/usr/bin/env bash

set -euxo pipefail

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
    pwd
)"

LIBREOFFICE_VERSION="${LIBREOFFICE_VERSION:-26.8.0}"
LIBREOFFICE_VERSION_MINOR="${LIBREOFFICE_VERSION_MINOR:-3}"
PACKAGE_REVISION="${PACKAGE_REVISION:-dbca1}"

LIBREOFFICE_FULL_VERSION="${LIBREOFFICE_VERSION}.${LIBREOFFICE_VERSION_MINOR}"
PACKAGE_VERSION="${LIBREOFFICE_FULL_VERSION}+${PACKAGE_REVISION}"

SOURCE_ROOT="${SCRIPT_DIR}/source"
SOURCE_DIRECTORY="${SOURCE_ROOT}/libreoffice-${LIBREOFFICE_FULL_VERSION}"
SOURCE_ARCHIVE="${SOURCE_ROOT}/libreoffice-${LIBREOFFICE_FULL_VERSION}.tar.xz"
ARTIFACT_DIRECTORY="${SCRIPT_DIR}/artifacts"

SOURCE_URL="https://download.documentfoundation.org/libreoffice/src/${LIBREOFFICE_VERSION}/libreoffice-${LIBREOFFICE_FULL_VERSION}.tar.xz"

export LIBREOFFICE_VERSION
export LIBREOFFICE_VERSION_MINOR
export LIBREOFFICE_FULL_VERSION
export PACKAGE_VERSION
export SOURCE_DIRECTORY

rm -rf "${SOURCE_ROOT}"
rm -rf "${ARTIFACT_DIRECTORY}"

mkdir -p "${SOURCE_ROOT}"
mkdir -p "${ARTIFACT_DIRECTORY}"

echo "LibreOffice source version: ${LIBREOFFICE_FULL_VERSION}"
echo "Debian package version:     ${PACKAGE_VERSION}"
echo "Source URL:                 ${SOURCE_URL}"

curl \
    --fail \
    --show-error \
    --location \
    --retry 5 \
    --retry-delay 10 \
    "${SOURCE_URL}" \
    --output "${SOURCE_ARCHIVE}"

tar \
    --extract \
    --xz \
    --file "${SOURCE_ARCHIVE}" \
    --directory "${SOURCE_ROOT}"

test -d "${SOURCE_DIRECTORY}"

cd "${SCRIPT_DIR}"

dpkg-buildpackage \
    --build=binary \
    --no-sign

find "${SCRIPT_DIR}/.." \
    -maxdepth 1 \
    -type f \
    -name 'libreoffice-dbca_*.deb' \
    -exec cp -v {} "${ARTIFACT_DIRECTORY}/" \;

PACKAGE_FILE="$(
    find "${ARTIFACT_DIRECTORY}" \
        -maxdepth 1 \
        -type f \
        -name 'libreoffice-dbca_*.deb' \
        -print \
        -quit
)"

if [[ -z "${PACKAGE_FILE}" ]]; then
    echo "ERROR: No LibreOffice Debian package was generated."
    exit 1
fi

dpkg-deb --info "${PACKAGE_FILE}"
dpkg-deb --contents "${PACKAGE_FILE}" | head -100

echo
echo "Package created successfully:"
echo "${PACKAGE_FILE}"
