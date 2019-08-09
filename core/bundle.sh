#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

cd "${CURRENT_OUT}"

bundle() {
    # The rootfs to bundle
    local rootdir="${1}"
    # Final bundle name
    local name="${2}"
    local dst="${2}.squashfs"

    sdk_info "Bundling the ${name} root in a squashfs image..."
    mksquashfs \
        "${rootdir}" \
        "${dst}" \
        -noI -noD -noF -noX -no-duplicates -noappend

    sdk_info "Formatting the ${name} root with dm-verity..."

    # Setup DM-Verity, store and retrieve root hash from the status output:
    veritysetup format \
        --fec-device="${dst}.verity.fec" -- "${dst}" "${dst}.verity" \
        | tee "${dst}.verity.status" \
        | gawk '(/^Root hash:/ && $NF ~ /^[0-9a-fA-F]+$/) { print $NF; }' \
        > "${dst}.verity.roothash"

    core_squashfs_size="$(stat -c '%s' "${dst}")"
    core_verity_size="$(stat -c '%s' "${dst}.verity")"

    core_bundled_hashoffset="$(( core_squashfs_size ))"
    core_bundled_fecoffset="$(( core_squashfs_size + core_verity_size ))"

    # Store verity root hash offset
    echo "${core_bundled_hashoffset}" > "${dst}.verity.bundled.hashoffset"
    # Store FEC data offset
    echo "${core_bundled_fecoffset}"  > "${dst}.verity.bundled.fecoffset"

    # Bundle squashfs contents with appended dm-verity information
    cat "${dst}" "${dst}.verity" "${dst}.verity.fec" > "${dst}.verity.bundled"
}

bundle "../configure/root" "core"

# Special case to create a second core bundle to test updates
if is_instrumentation_feature_enabled "test-update"; then
    # Copy the rootfs into a writable location
    cp -a "../configure/root" "${CURRENT_OUT}"

    # Increase the version number
    version=${CURRENT_PRODUCT_VERSION##*.}
    next_version=$((version+1))
    next_version=${CURRENT_PRODUCT_VERSION/%${version}/${next_version}}
    sed -i "s|${CURRENT_PRODUCT_VERSION}|${next_version}|g" "${CURRENT_OUT_ROOT}/etc/os-release"

    bundle "root" "core.next"

    # Remove now unneeded rootfs
    rm -rf "${CURRENT_OUT_ROOT}"
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
