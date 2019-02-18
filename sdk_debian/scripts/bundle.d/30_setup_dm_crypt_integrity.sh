#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Setup DM-Crypt+Integrity for LV_NAME Logical Volume and create an ext4
# filesystem inside the image IMAGE_DISK_FILE.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly IMAGE_DISK_FILE="${1:?IMAGE_DISK_FILE is needed}"
readonly LV_NAME="${2:?LV_NAME is needed}"

# Main LVM volume group name
readonly VG_NAME="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"

if [[ ! -f "${IMAGE_DISK_FILE}" ]]; then
    sdk_die "${IMAGE_DISK_FILE} does not exist!"
fi

# We make use of libguestfs in the following commands to create the disk image
# where CLIP OS will be installed. This environment variable tells libguestfs to
# use directly QEMU-KVM without the need of the libvirt daemon.
export LIBGUESTFS_BACKEND=direct

luks_key="$(cat ${CURRENT_CACHE}/${LV_NAME}.keyfile)"

# FIXME: Usage of 'debug sh' is less than ideal but we don't have any other
# option as long as libguestfs doesn't support DM-Integrity and arbitrary LUKS
# setup. This is fine for now as this is unlikely to break in the future and
# would only impact the QEMU virtual image anyway, not real hardware
# installations.
sdk_begin "${IMAGE_DISK_FILE}: Setting up DM-Crypt+Integrity for ${LV_NAME}..."
guestfish --rw <<_EOF_
add-drive ${IMAGE_DISK_FILE} label:main format:qcow2

run

debug sh "echo -n '${luks_key}' | cryptsetup luksFormat \
    --batch-mode \
    --type luks2 \
    --cipher aes-xts-plain64 \
    --integrity hmac-sha256 \
    --pbkdf argon2i \
    --label core_state \
    --key-file - \
    /dev/${VG_NAME}/${LV_NAME}"
_EOF_
sdk_end "${IMAGE_DISK_FILE}: Setting up DM-Crypt+Integrity for ${LV_NAME}: OK"

sdk_begin "${IMAGE_DISK_FILE}: Creating ext4 filesystem in ${LV_NAME}..."
guestfish --rw --keys-from-stdin <<_EOF_
add-drive ${IMAGE_DISK_FILE} label:main format:qcow2

run

luks-open /dev/${VG_NAME}/${LV_NAME} core_state
${luks_key}

mkfs ext4 /dev/mapper/core_state
_EOF_
sdk_end "${IMAGE_DISK_FILE}: Setting up DM-Crypt+Integrity for ${LV_NAME}: OK"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
