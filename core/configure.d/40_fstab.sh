#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh


# FIXME: Move most for those entries to .mount units
# FIXME: Hardcode version number in core_XXX entries
# FIXME: add /proc restrictions
# FIXME: Remove /tmp & make it chmod 500

readonly vg_name="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"
readonly core_lv_name="core_${CURRENT_PRODUCT_VERSION}"

# Empty out pre-existing /etc/fstab & /etc/crypttab
true > "${CURRENT_OUT_ROOT}/etc/fstab"
true > "${CURRENT_OUT_ROOT}/etc/crypttab"


einfo "Setup default /etc/fstab."
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
einfo "Add core rootfs configuration."
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/mapper/${vg_name}-${core_lv_name}  /  squashfs  ro  0 0
EOF

einfo "Add /mnt to store all further mount points"
install -d -m 0755 "${CURRENT_OUT_ROOT}/mnt"

einfo "Add efiboot mountpoint configuration."
install -d -m 0700 "${CURRENT_OUT_ROOT}/mnt/efiboot"
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/disk/by-partlabel/EFI  /mnt/efiboot  vfat  rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro  0 2
EOF

einfo "Add core state configuration."
install -d -m 0755 "${CURRENT_OUT_ROOT}/mnt/state"
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/mapper/core_state  /mnt/state  ext4  rw,nodev,noexec,nosuid       0 2
/mnt/state/core/var/    /var        none  rw,bind,nodev,noexec,nosuid  0 0
EOF

einfo "Add swap configuration."
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/fstab"
/dev/mapper/swap  none  swap  defaults  0 0
EOF

cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/crypttab"
swap  /dev/mapper/${vg_name}-core_swap  /dev/urandom  swap
EOF

# vim: set ts=4 sts=4 sw=4 et ft=sh:
