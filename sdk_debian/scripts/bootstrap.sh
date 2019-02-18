#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# CLIP OS SDK setup script

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

DEBIAN_ASSETS_DIR="/mnt/assets/debian"
DEBIAN_PKG_SRC_DIR="${DEBIAN_ASSETS_DIR}/src"

# Download package sources only if they are not already available
if [[ ! -d "${DEBIAN_PKG_SRC_DIR}" ]]; then
    sdk_info "Adding source URIs"
    echo "deb-src http://debian.mirrors.ovh.net/debian/ unstable main" \
        >> /etc/apt/sources.list

    sdk_info "Updating package lists"
    apt update

    rm -rf "${DEBIAN_PKG_SRC_DIR}"
    mkdir -p "${DEBIAN_PKG_SRC_DIR}"

    sdk_info "Downloading sources for all installed packages"
    dpkg-query -W -f '${Package}\n' | sort -u | while read package; do
        rm -rf "${DEBIAN_PKG_SRC_DIR}/${package}"
        # Allow _apt user inside the SDK to download as non-root
        mkdir -p -m=777 "${DEBIAN_PKG_SRC_DIR}/${package}"
        pushd "${DEBIAN_PKG_SRC_DIR}/${package}"
        apt-get -d -q source "${package}"
        popd
    done

    sdk_info "Fixing permissions"
    fixup_uid="$(stat -c '%u' ${DEBIAN_ASSETS_DIR})"
    fixup_gid="$(stat -c '%g' ${DEBIAN_ASSETS_DIR})"
    chown -R "${fixup_uid}:${fixup_gid}" "${DEBIAN_PKG_SRC_DIR}"
    chmod -R go-w "${DEBIAN_PKG_SRC_DIR}"
fi

sdk_info "Done"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
