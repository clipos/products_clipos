#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh


# FIXME: Move most for those entries to .mount units
# FIXME: add /proc restrictions
# FIXME: Remove /tmp & make it chmod 500

readonly vg_name="${COSMK_PRODUCT_ENV_VG_NAME}"
readonly core_lv_name="core_${COSMK_PRODUCT_VERSION}"

# Empty out pre-existing /etc/fstab & /etc/crypttab
true > "${CURRENT_OUT_ROOT}/etc/fstab"
true > "${CURRENT_OUT_ROOT}/etc/crypttab"


sdk_info "Setup default /etc/fstab."
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
tmpfs     /dev/shm                   tmpfs     rw,nosuid,nodev,noexec           0 0
tmpfs     /run                       tmpfs     rw,nosuid,nodev,noexec,mode=755  0 0
tmpfs     /tmp                       tmpfs     rw,nosuid,nodev,noexec           0 0
efivarfs  /sys/firmware/efi/efivars  efivarfs  ro,nosuid,nodev,noexec,relatime  0 0
EOF

# /usr   /usr   none  ro,bind,nodev                0 0
# /bin   /bin   none  ro,bind,nodev                0 0
# /sbin  /sbin  none  ro,bind,nodev                0 0
# /etc   /etc   none  ro,bind,nodev,noexec,nosuid  0 0
sdk_info "Add core rootfs configuration."
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/mapper/${vg_name}-${core_lv_name}  /  squashfs  ro  0 0
EOF

sdk_info "Add /mnt to store all further mount points"
install -d -m 0755 "${CURRENT_OUT_ROOT}/mnt"

sdk_info "Add efiboot mountpoint configuration."
install -d -m 0700 "${CURRENT_OUT_ROOT}/mnt/efiboot"
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/disk/by-partlabel/EFI  /mnt/efiboot  vfat  rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro  0 2
EOF

sdk_info "Add core state configuration."
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/mapper/core_state  /mnt/state  ext4  rw,nodev,noexec,nosuid       0 2
EOF

sdk_info "Create directories for state partition mountpoints."
install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT_ROOT}/mnt/state"

sdk_info "Add swap configuration."
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/mapper/swap  none  swap  defaults  0 0
EOF

cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/crypttab"
swap  /dev/mapper/${vg_name}-core_swap  /dev/urandom  swap
EOF

# vim: set ts=4 sts=4 sw=4 et ft=sh:
