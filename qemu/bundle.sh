#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly empty_disk_image="${CURRENT_CACHE}/empty.qcow2"
readonly final_disk_image="${CURRENT_OUT}/main.qcow2"
readonly core_state_keyfile="${CURRENT_CACHE}/core_state.keyfile"

readonly core_lv_name="core_${CURRENT_PRODUCT_VERSION}"

readonly current="/mnt/out/${CURRENT_PRODUCT}/${CURRENT_PRODUCT_VERSION}"
readonly efiboot="${current}/efiboot/bundle/efipartition.tar"
readonly core_root="${current}/core/bundle/core.squashfs.verity.bundled"
readonly qemu_core_state="${CURRENT_OUT}/qemu-core-state.tar"

# Re-use cached empty disk image if available
if [[ ! -f "${empty_disk_image}" ]] || [[ ! -f "${core_state_keyfile}" ]]; then
    ${CURRENT_SDK}/scripts/bundle.d/10_create_disk_image.sh \
        "${empty_disk_image}" qcow2 20G

    # Sizes are in MB (See http://libguestfs.org/guestfish.1.html#lvcreate)
    ${CURRENT_SDK}/scripts/bundle.d/20_insert_empty_lv.sh \
        "${empty_disk_image}" "${core_lv_name}" 4096
    ${CURRENT_SDK}/scripts/bundle.d/20_insert_empty_lv.sh \
        "${empty_disk_image}" core_state 512
    ${CURRENT_SDK}/scripts/bundle.d/20_insert_empty_lv.sh \
        "${empty_disk_image}" core_swap 1024

    echo -n "core_state_key" > "${core_state_keyfile}"
    ${CURRENT_SDK}/scripts/bundle.d/30_setup_dm_crypt_integrity.sh \
        "${empty_disk_image}" core_state
else
    ewarn "Re-using cached empty QEMU disk image!"
fi

# Work on a copy of the cached empty disk image
cp -v "${empty_disk_image}" "${final_disk_image}"

${CURRENT_SDK}/scripts/bundle.d/50_insert_efiboot.sh \
    "${final_disk_image}" "${efiboot}"

${CURRENT_SDK}/scripts/bundle.d/51_insert_image.sh \
    "${final_disk_image}" "${core_root}" "${core_lv_name}"

# Generate & install core_state initial content
/mnt/products/${CURRENT_PRODUCT}/${CURRENT_RECIPE}/bundle.d/generate_core_state.sh
${CURRENT_SDK}/scripts/bundle.d/52_insert_fs_tar.sh \
    "${final_disk_image}" "${qemu_core_state}" core_state

# vim: set ts=4 sts=4 sw=4 et ft=sh:
