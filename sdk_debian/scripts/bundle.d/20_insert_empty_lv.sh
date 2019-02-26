#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Insert an empty Logical Volume with name LV_NAME and size LV_SIZE inside
# IMAGE which must be a CLIP OS prepared disk image.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly IMAGE_DISK_FILE="${1:?IMAGE_DISK_FILE is needed}"
readonly LV_NAME="${2:?LV_NAME is needed}"
readonly LV_SIZE="${3:?LV_SIZE is needed}"

# Main LVM volume group name
readonly VG_NAME="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"

# We make use of libguestfs in the following commands to create the disk image
# where CLIP OS will be installed. This environment variable tells libguestfs
# to use directly QEMU-KVM without the need of the libvirt daemon.
export LIBGUESTFS_BACKEND=direct

ebegin "${IMAGE_DISK_FILE}: Adding empty ${LV_NAME}:${LV_SIZE}M..."
guestfish --rw <<_EOF_
add-drive ${IMAGE_DISK_FILE} label:main

run

lvcreate ${LV_NAME} ${VG_NAME} ${LV_SIZE}
_EOF_
eend "${IMAGE_DISK_FILE}: Adding empty ${LV_NAME}:${LV_SIZE}M: OK"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
