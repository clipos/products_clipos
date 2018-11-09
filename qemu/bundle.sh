#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly empty_disk_image="${CURRENT_CACHE}/empty.qcow2"
readonly final_disk_image="${CURRENT_OUT}/main.qcow2"

readonly core_lv_name="core_${CURRENT_PRODUCT_VERSION}"

readonly current="/mnt/out/${CURRENT_PRODUCT}/${CURRENT_PRODUCT_VERSION}"
readonly efiboot="${current}/efiboot/bundle/efipartition.tar"
readonly core_root="${current}/core/bundle/core.squashfs.verity.bundled"
readonly core_state="${current}/core/bundle/core-state.tar"

# Re-use cached empty disk image if available
if [[ ! -f "${empty_disk_image}" ]]; then
    ${CURRENT_SDK}/scripts/bundle.d/10_create_disk_image.sh \
        "${empty_disk_image}" qcow2 20G

    ${CURRENT_SDK}/scripts/bundle.d/20_insert_empty_lv.sh \
        "${empty_disk_image}" "${core_lv_name}" 4096
    ${CURRENT_SDK}/scripts/bundle.d/20_insert_empty_lv.sh \
        "${empty_disk_image}" core_state 4096
    ${CURRENT_SDK}/scripts/bundle.d/20_insert_empty_lv.sh \
        "${empty_disk_image}" core_swap 1024

    ${CURRENT_SDK}/scripts/bundle.d/30_setup_ext4.sh \
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

${CURRENT_SDK}/scripts/bundle.d/52_insert_fs_tar.sh \
    "${final_disk_image}" "${core_state}" core_state

# vim: set ts=4 sts=4 sw=4 et ft=sh:
