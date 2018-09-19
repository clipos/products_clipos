#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly qemu_disk_image="${CURRENT_OUT}/main.qcow2"
readonly current="/mnt/out/${CURRENT_PRODUCT}/${CURRENT_PRODUCT_VERSION}"
readonly core_lv_name="core_${CURRENT_PRODUCT_VERSION}"
readonly clip_core_root="${current}/core/bundle/core.squashfs.verity.bundled"
readonly clip_core_state="${current}/core/bundle/core-state.tar"
readonly clip_efiboot="${current}/efiboot/bundle/efipartition.tar"

/mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/disk-images/disk-create.sh \
    "${qemu_disk_image}" qcow2 20G

/mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/disk-images/disk-insert-efiboot.sh \
    "${qemu_disk_image}" "${clip_efiboot}"

/mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/disk-images/disk-insert-lv.sh \
    "${qemu_disk_image}" "${clip_core_root}" "${core_lv_name}" 4096

/mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/disk-images/disk-insert-state-lv.sh \
    "${qemu_disk_image}" "${clip_core_state}" core_state 4096

/mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/disk-images/disk-insert-empty-lv.sh \
    "${qemu_disk_image}" core_swap 1024

# vim: set ts=4 sts=4 sw=4 et ft=sh:
