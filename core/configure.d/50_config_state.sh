#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# einfo "Create /etc state directory."
# install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT}/state/core/etc"

# einfo "Setup clipos configuration directory."
# install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT}/state/core/etc/clipos"
# ln -s "/mnt/state/core/etc/clipos" "${CURRENT_OUT_ROOT}/etc/clipos"

# TODO: machine-id & hostname must be set at installation time only
# TODO: This requires dracut config for initramfs setup of state partition
# ln -sf "/mnt/state/core/etc/hostname"   "${CURRENT_OUT_ROOT}/etc/hostname"
# ln -sf "/mnt/state/core/etc/machine-id" "${CURRENT_OUT_ROOT}/etc/machine-id"
einfo "Set fixed known machine-id & hostname for now."
SHORT_NAME="${CURRENT_PRODUCT_PROPERTY['short_name']}"
echo "${SHORT_NAME:?}-qemu" > "${CURRENT_OUT_ROOT}/etc/hostname"
echo "${SHORT_NAME:?}-qemu" | md5sum | awk '{print $1}' > "${CURRENT_OUT_ROOT}/etc/machine-id"

einfo "Setup state directory for kernel modules config"
install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT}/state/core/etc/modules-load.d"
install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT_ROOT}/etc/modules-load.d"
ln -sf "/mnt/state/core/etc/modules-load.d/hardware.conf" \
    "${CURRENT_OUT_ROOT}/etc/modules-load.d/hardware.conf"

# FIXME: this is specific to the QEMU environment; in the future, the symbolic
# link will be created at installation time only.
einfo "Add default hardware profile"
ln -sf "/usr/share/clipos-hardware/profiles/kvm_ovmf64/modules" \
    "${CURRENT_OUT}/state/core/etc/modules-load.d/hardware.conf"

# vim: set ft=sh ts=4 sts=4 sw=4 et:
