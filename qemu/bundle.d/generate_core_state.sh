#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Setup the minimal required layout for the state partition.
# This only includes files that must exist before the initramfs pivot_root or
# before the systemd-tmpfiles setup completes. Other state files should be
# setup using systemd-tmpfiles.

# This is required as long as we don't have installer support for QEMU images.
# This setup will be done by the installer for real hardware.

readonly CURRENT_STATE="${CURRENT_OUT}/qemu-state"

mkdir "${CURRENT_STATE}"

# hostname & machine-id
readonly PRODUCT_NAME="${CURRENT_PRODUCT_PROPERTY['short_name']}"
install -o 0 -g 0 -m 0755 -d "${CURRENT_STATE}/core/etc"
echo "${PRODUCT_NAME:?}-qemu" > "${CURRENT_STATE}/core/etc/hostname"
echo "${PRODUCT_NAME:?}-qemu" | md5sum | awk '{print $1}' > "${CURRENT_STATE}/core/etc/machine-id"

# /var/log/journal
# systemd-journal GID must match the one set in core/configure rootfs
journald_gid="$(grep "systemd-journal:" "/mnt/out/${CURRENT_PRODUCT}/${CURRENT_PRODUCT_VERSION}/core/configure/root/etc/group" | cut -d: -f 3)"
install -o 0 -g "${journald_gid}" -m 2755 -d "${CURRENT_STATE}/core/var/log/journal"

# Loaded modules
install -o 0 -g 0 -m 0755 -d "${CURRENT_STATE}/core/etc/modules-load.d"
ln -sf "/usr/share/clipos-hardware/profiles/kvm_ovmf64/modules" \
    "${CURRENT_STATE}/core/etc/modules-load.d/hardware.conf"

# Network setup
install -o 0 -g 0 -m 0755 -d "${CURRENT_STATE}/core/etc/systemd/network"
cat > "${CURRENT_STATE}/core/etc/systemd/network/10-wired.network" << EOF
[Match]
Name=en*

[Network]
DHCP=ipv4
# Address=192.168.XX.YY/24
# Gateway=192.168.XX.1
# DNS=192.168.150.1
EOF

# Touch a specific file to enable simple initramfs check.
touch "${CURRENT_STATE}/.setup-done"

einfo "Creating QEMU initial core state tarball..."
# Bundle the state folder content as a tarball while making sure to keep
# filesystem advanced properties such as sparse information or extended
# attributes:
tar --create --xattrs --sparse \
    --file "${CURRENT_OUT}/qemu-core-state.tar" \
    --directory "${CURRENT_STATE}" \
    .

# vim: set ts=4 sts=4 sw=4 et ft=sh:
