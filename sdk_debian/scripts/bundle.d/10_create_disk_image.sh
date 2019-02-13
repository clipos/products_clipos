#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Create an empty CLIP OS image IMAGE with type TYPE and size SIZE.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly IMAGE_FILE="${1:?IMAGE_FILE is needed}"
readonly IMAGE_TYPE="${2:?IMAGE_TYPE is needed}"
readonly IMAGE_SIZE="${3:?IMAGE_SIZE is needed}"

# Main LVM volume group name
readonly VG_NAME="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"

ebegin "${IMAGE_FILE}: Creating disk image as ${IMAGE_TYPE} ${IMAGE_SIZE}..."

readonly BOOT_PARTITION_SIZE="536870912"  # 512 Mio

rm -f "${IMAGE_FILE}"

# We make use of libguestfs in the following commands to create the disk image
# where CLIP OS will be installed. This environment variable tells libguestfs
# to use directly QEMU-KVM without the need of the libvirt daemon.
export LIBGUESTFS_BACKEND=direct

# Nomenclature for the following variables:
#   _bsz => size in bytes
#   _ssz => size in sectors LBA are always in sectors (obviously)
disk_bsz=0 boot_bsz=0 lvm_bsz=0
disk_ssz=0 boot_ssz=0 lvm_ssz=0
boot_lbastart=0 lvm_lbastart=0
firstlba=0 lastlba=0

einfo "${IMAGE_FILE}: Getting blockdev-getsz..."
disk_ssz="$(guestfish --rw <<_EOF_
disk-create ${IMAGE_FILE} ${IMAGE_TYPE} ${IMAGE_SIZE}
add-drive ${IMAGE_FILE} label:main

run

blockdev-getsz /dev/disk/guestfs/main
_EOF_
)"
einfo "${IMAGE_FILE}: Getting blockdev-getsz: OK"

firstlba=2048   # => 1 Mio
# We deliberately leave 1 Mio free in the beginning of the disk to be sure to
# be aligned (and 1 Mio is nearly free nowadays) with physical sector size
# whatever their size (512b, 4K, 8K, etc.) and to leave enough free space for
# the GUID partition table header.
lastlba="$((disk_ssz - 34))"  # LBA 34 is the first usable on disk

boot_bsz="$BOOT_PARTITION_SIZE"
boot_ssz="$((boot_bsz / 512))"
boot_lbastart="$firstlba"
boot_lbaend="$((firstlba + boot_ssz - 1))"

lvm_lbastart="$((boot_lbastart + boot_ssz))"
lvm_ssz="$((lastlba + 1 - lvm_lbastart))"
lvm_bsz="$((lvm_ssz * 512))"

einfo "${IMAGE_FILE}: Creating disk and partitions..."
guestfish --rw <<_EOF_
add-drive ${IMAGE_FILE} label:main

run

part-init /dev/disk/guestfs/main gpt

part-add /dev/disk/guestfs/main p ${boot_lbastart} ${boot_lbaend}
part-set-gpt-type /dev/disk/guestfs/main 1 C12A7328-F81F-11D2-BA4B-00A0C93EC93B
part-set-name /dev/disk/guestfs/main 1 EFI

part-add /dev/disk/guestfs/main p ${lvm_lbastart} ${lastlba}
part-set-gpt-type /dev/disk/guestfs/main 2 E6D6D379-F507-44C2-A23C-238F2A3DF928
part-set-name /dev/disk/guestfs/main 2 LVM
_EOF_
einfo "${IMAGE_FILE}: Creating disk and partitions: OK"

einfo "${IMAGE_FILE}: Creating vfat on EFI & LVM..."
guestfish --rw <<_EOF_
add-drive ${IMAGE_FILE} label:main

run

mkfs vfat /dev/disk/guestfs/main1 label:EFI
pvcreate /dev/disk/guestfs/main2
vgcreate ${VG_NAME} /dev/disk/guestfs/main2
_EOF_
einfo "${IMAGE_FILE}: Creating vfat on EFI & LVM: OK"

chmod a+rw "${IMAGE_FILE}"

eend "${IMAGE_FILE}: Done"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
