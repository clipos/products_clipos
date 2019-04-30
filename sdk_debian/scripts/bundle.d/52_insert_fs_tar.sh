#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Insert the content of TAR archive in the DM-Crypt/Integrity device in LV_NAME
# Logical Volume inside IMAGE which must be a CLIP OS prepared disk image.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly IMAGE_DISK_FILE="${1:?IMAGE_DISK_FILE is needed}"
readonly TAR_FILE="${2:?TAR_FILE is needed}"
readonly LV_NAME="${3:?LV_NAME is needed}"

# Main LVM volume group name
readonly VG_NAME="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"

if [[ ! -f "${IMAGE_DISK_FILE}" ]]; then
    sdk_die "${IMAGE_DISK_FILE} does not exist!"
fi
if [[ ! -f "${TAR_FILE}" ]]; then
    sdk_die "${TAR_FILE} does not exist!"
fi

# We make use of libguestfs in the following commands to create the disk image
# where CLIP OS will be installed. This environment variable tells libguestfs
# to use directly QEMU-KVM without the need of the libvirt daemon.
export LIBGUESTFS_BACKEND=direct

luks_key="$(cat ${CURRENT_CACHE}/${LV_NAME}.keyfile)"

sdk_begin "${IMAGE_DISK_FILE}: Adding ${TAR_FILE} in ${LV_NAME}..."
guestfish --rw --keys-from-stdin <<_EOF_
add-drive ${IMAGE_DISK_FILE} label:main format:qcow2

run

luks-open /dev/${VG_NAME}/${LV_NAME} core_state
${luks_key}

mount /dev/mapper/core_state /
tar-in ${TAR_FILE} /
_EOF_
eend "${IMAGE_DISK_FILE}: Adding ${TAR_FILE} in ${LV_NAME}: OK"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
